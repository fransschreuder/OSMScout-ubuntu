/*
 OSMScout - a Qt backend for libosmscout and libosmscout-map
 Copyright (C) 2010  Tim Teulings

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include "DBThread.h"

#include <cmath>
#include <iostream>

#include <QApplication>
#include <QMutexLocker>
//#include <QDebug>
#include <QDir>
#include <QMessageBox>
#include <QSettings>

#include <osmscout/util/StopClock.h>

QBreaker::QBreaker()
  :osmscout::Breaker()
  ,aborted(false)
{
}

bool QBreaker::Break(){
  QMutexLocker locker(&mutex);
  aborted = true;
  return true;
}

bool QBreaker::IsAborted() const
{
  QMutexLocker locker(&mutex);
  return aborted;
}

void QBreaker::Reset()
{
  QMutexLocker locker(&mutex);
  aborted = false;
}


DBThread::DBThread()
 : database(new osmscout::Database(databaseParameter)),
   locationService(new osmscout::LocationService(database)),
   mapService(new osmscout::MapService(database)),
   painter(NULL),
   iconDirectory(),
   currentImage(NULL),
   currentLat(0.0),
   currentLon(0.0),
   currentAngle(0.0),
   currentMagnification(0),
   finishedImage(NULL),
   finishedLat(0.0),
   finishedLon(0.0),
   finishedMagnification(0),
   currentRenderRequest(),
   doRender(false),
   renderBreaker(new QBreaker()),
   renderBreakerRef(renderBreaker)
{
    QScreen *srn = QApplication::screens().at(0);

    dpi = (double)srn->physicalDotsPerInch();
}

void DBThread::FreeMaps()
{
  delete currentImage;
  currentImage=NULL;

  delete finishedImage;
  finishedImage=NULL;
}

bool DBThread::AssureRouter(osmscout::Vehicle vehicle)
{
  if (!database->IsOpen()) {
    return false;
  }

  if (!router ||
      (router && router->GetVehicle()!=vehicle)) {
    if (router) {
      if (router->IsOpen()) {
        router->Close();
      }
      router=NULL;
    }

    router=std::make_shared<osmscout::RoutingService>(database,
                                                      routerParameter,
                                                      vehicle);

    if (!router->Open()) {
      return false;
    }
  }

  return true;
}

bool DBThread::testWritable(QString path)const
{
    QFile tempFile(path+"/tempfile"); //test if we can write here...
    if(!tempFile.open(QFile::WriteOnly))
    {
        qDebug()<<"Could not write to: "+path+"/tempfile";
        return false;
    }
    if(!tempFile.remove()){
        qDebug()<<"Could not remove file: "+path+"/tempfile";;
        return false;
    }
    return true;
}

QStringList DBThread::getValidDownloadDirs() const
{
    QStringList docPaths=QStandardPaths::standardLocations(QStandardPaths::DocumentsLocation);
    QString s = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    docPaths.prepend(s.left(s.lastIndexOf("/osmscout")));

#ifdef __UBUNTU__
    ///TODO: search removable drives using QStorageInfo, will be available in Vivid
    //QList<QStorageInfo> volumes = QStorageInfo::mountedVolumes();
    QDir mediaPath("/media");
    QStringList removableUserList = mediaPath.entryList(QDir::NoDotAndDotDot | QDir::Dirs);
    for(int i=0; i<removableUserList.size(); i++) //find <user directories in media
    {
        std::cout<<"Found user: "<<removableUserList[i].toLocal8Bit().data()<<std::endl;
        QDir removablePath("/media/"+removableUserList[i]);
        QStringList removablePaths = removablePath.entryList(QDir::NoDotAndDotDot | QDir::Dirs);
        for(int j=0; j<removablePaths.size(); j++)
        {
            std::cout<<"Found removable path: "<<("/media/"+removableUserList[i]+"/"+removablePaths[j]).toLocal8Bit().data()<<std::endl;
            docPaths.append("/media/"+removableUserList[i]+"/"+removablePaths[j]);
        }
    }
#endif
    for(int i=0; i<docPaths.size(); i++)
    {
        QDir _rootDir(docPaths[i]);
        _rootDir.mkdir(docPaths[i]);
        QDir rootDir(docPaths[i]+"/Maps"); //last one is preferred first
        QFileInfo fi(docPaths[i]);
        if(!rootDir.exists()||!fi.isDir())
        {
            if(!rootDir.mkdir(docPaths[i]+"/Maps")){
                docPaths.removeAt(i);
                i--;
                qDebug()<<"Could not create "<<docPaths[i]<<"/Maps";
                continue;
            }

        }
        if(!this->testWritable(docPaths[i]+"/Maps"))
        {
            docPaths.removeAt(i);
            i--;
            qDebug()<<"Path not writable";
            continue;
        }
    }
    return docPaths;
}

QString DBThread::getPreferredDownloadDir() const
{
    QStringList docPaths = getValidDownloadDirs();
    QSettings s;
    int defaultDownloadFolder = s.value("defaultDownloadFolder", docPaths.size()-1).toInt();


    if(defaultDownloadFolder>=docPaths.size())defaultDownloadFolder=docPaths.size()-1;

    if(docPaths.size()>0)return docPaths[defaultDownloadFolder]+"/Maps";
    qDebug()<<"Could not find directory to write to";
    return "";
}

QStringList DBThread::findValidMapDirs() const
{
    QStringList docPaths = getValidDownloadDirs();

    QStringList validMapDirs;
    for(int i=0; i<docPaths.size(); i++)
    {
        docPaths[i].append("/Maps");
        std::cout<<"Looking into path: "<<docPaths[i].toLocal8Bit().data()<<std::endl;
        QDir mapsPath(docPaths[i]);
        QStringList mapsSubDirs = mapsPath.entryList(QDir::NoDotAndDotDot | QDir::Dirs); //find all different map subfolders in the Maps folder
        for(int j=0; j<mapsSubDirs.size(); j++)
        {
            QDir mapFilesPath(docPaths[i]+"/"+mapsSubDirs[j]);
            QStringList mapFiles = mapFilesPath.entryList(QDir::Files);
            for(int k=0; k< mapFiles.size(); k++)
            {
                if(mapFiles[k] == "standard.oss")
                {
                    validMapDirs.append(docPaths[i]+"/"+mapsSubDirs[j]);
                }
            }
        }

    }
    return validMapDirs;
}

void DBThread::Initialize()
{
    QSettings settings;//(QSettings::UserScope, "osmscout.fransschreuder", "osmscout");
    std::cout<<"Settings.status: "<<settings.status()<<std::endl;
    int selectedMap = settings.value("selectedmap", 0).toInt();
    settings.setValue("selectedmap", selectedMap);
    std::cout<<"Settings filename "<<settings.fileName().toLocal8Bit().data()<<std::endl;


    QStringList mapDirs = findValidMapDirs();
    if(mapDirs.size()<=0)
    {
        std::cout<<"Could not find valid map dir"<<std::endl;
        return;
    }
    if(selectedMap>=mapDirs.size())
    {
        selectedMap = 0;
    }
    QString databaseDirectory = mapDirs[selectedMap];
    QString stylesheetFilename=databaseDirectory+"/standard.oss";
  if (database->Open(databaseDirectory.toLocal8Bit().data())) {
    osmscout::TypeConfigRef typeConfig=database->GetTypeConfig();

    if (typeConfig) {
      styleConfig=new osmscout::StyleConfig(typeConfig);

      delete painter;
      painter=NULL;

      if (styleConfig->Load(stylesheetFilename.toLocal8Bit().data())) {
          painter=new osmscout::MapPainterQt(styleConfig);
      }
      else {
        //qDebug() << "Cannot load style sheet!";
        styleConfig=NULL;
      }
    }
    else {
      //qDebug() << "TypeConfig invalid!";
      styleConfig=NULL;
    }
  }
  else {
    //qDebug() << "Cannot open database!";
    return;
  }


  DatabaseLoadedResponse response;

  if (!database->GetBoundingBox(response.boundingBox)) {
    //qDebug() << "Cannot read initial bounding box";
    return;
  }
  emit InitialisationFinished(response);
}

void DBThread::Finalize()
{
  FreeMaps();

  if (router && router->IsOpen()) {
    router->Close();
  }

  if (database->IsOpen()) {
    database->Close();
  }
}

void DBThread::GetProjection(osmscout::MercatorProjection& projection)
{
    QMutexLocker locker(&mutex);

    projection=this->projection;
}

void DBThread::UpdateRenderRequest(const RenderMapRequest& request)
{
  QMutexLocker locker(&mutex);

  currentRenderRequest=request;
  doRender=true;

  renderBreaker->Break();
}

void DBThread::TriggerMapRendering()
{
  RenderMapRequest request;
  {
    QMutexLocker locker(&mutex);

    request=currentRenderRequest;
    if (!doRender) {
      return;
    }



    renderBreaker->Reset();
  }

  if (currentImage==NULL ||
      currentImage->width()!=(int)request.width ||
      currentImage->height()!=(int)request.height) {
    delete currentImage;

    currentImage=new QImage(QSize(request.width,request.height),QImage::Format_RGB32);
  }

  currentLon=request.lon;
  currentLat=request.lat;
  currentAngle=request.angle;
  currentMagnification=request.magnification;
  QPainter p;
  if (database->IsOpen() &&
      styleConfig) {
    osmscout::MapParameter        drawParameter;
    osmscout::AreaSearchParameter searchParameter;

    searchParameter.SetBreaker(renderBreakerRef);
    searchParameter.SetMaximumAreaLevel(4);
    searchParameter.SetUseMultithreading(currentMagnification.GetMagnification()<=osmscout::Magnification::magCity);

    std::list<std::string>        paths;

    paths.push_back(iconDirectory.toLocal8Bit().data());

    drawParameter.SetIconPaths(paths);
    drawParameter.SetPatternPaths(paths);
    drawParameter.SetDebugPerformance(true);
    drawParameter.SetOptimizeWayNodes(osmscout::TransPolygon::quality);
    drawParameter.SetOptimizeAreaNodes(osmscout::TransPolygon::quality);
    drawParameter.SetRenderSeaLand(true);
    drawParameter.SetBreaker(renderBreakerRef);
    double fs = drawParameter.GetFontSize();
    QSettings s;
    double fsMul = s.value("fontSize", .5).toDouble();
    qDebug()<<"FontSize: "<<fs;
    qDebug()<<"DPI:" << dpi;
    fs=(dpi/50)*fsMul; //for 100DPI, multiply by 1.5
    drawParameter.SetFontSize(fs);

    std::cout << std::endl;

    osmscout::StopClock overallTimer;

    projection.Set(currentLon,
                   currentLat,
                   currentAngle,
                   currentMagnification,
                   dpi,
                   request.width,
                   request.height);

    osmscout::StopClock dataRetrievalTimer;

    mapService->GetObjects(searchParameter,
                           styleConfig,
                           projection,
                           data);

    if (drawParameter.GetRenderSeaLand()) {
      mapService->GetGroundTiles(projection,
                                 data.groundTiles);
    }

    dataRetrievalTimer.Stop();

    osmscout::StopClock drawTimer;



    p.begin(currentImage);
    p.setRenderHint(QPainter::Antialiasing);
    p.setRenderHint(QPainter::TextAntialiasing);
    p.setRenderHint(QPainter::SmoothPixmapTransform);

    painter->DrawMap(projection,
                     drawParameter,
                     data,
                     &p);

    p.end();

    drawTimer.Stop();
    overallTimer.Stop();

    std::cout << "All: " << overallTimer << " Data: " << dataRetrievalTimer << " Draw: " << drawTimer << std::endl;
  }
  else {
    std::cout << "Cannot draw map: " << database->IsOpen() << " " << styleConfig.Valid() << std::endl;

    p.begin(currentImage);
    p.setRenderHint(QPainter::Antialiasing);
    p.setRenderHint(QPainter::TextAntialiasing);
    p.setRenderHint(QPainter::SmoothPixmapTransform);

    p.fillRect(0,0,request.width,request.height,
               QColor::fromRgbF(0.0,0.0,0.0,1.0));

    p.setPen(QColor::fromRgbF(1.0,1.0,1.0,1.0));

    QString text("not initialized (yet)");

    p.drawText(QRect(0,0,request.width,request.height),
               Qt::AlignCenter|Qt::AlignVCenter,
               text,
               NULL);

    p.end();
  }

  QMutexLocker locker(&mutex);

  if (renderBreaker->IsAborted()) {
    return;
  }

  std::swap(currentImage,finishedImage);
  std::swap(currentLon,finishedLon);
  std::swap(currentLat,finishedLat);
  std::swap(currentAngle,finishedAngle);
  std::swap(currentMagnification,finishedMagnification);
  doRender=false;
  emit HandleMapRenderingResult();
}

bool DBThread::RenderMapQuick(QPainter& painter,
                              double dx, double dy, double zoomLevel, const RenderMapRequest& request)
{
    if (finishedImage==NULL || !styleConfig) {
      painter.fillRect(0,0,request.width, request.height,
                       QColor::fromRgbF(1.0,0.0,0.0,1.0));

      painter.setPen(QColor::fromRgbF(1.0,1.0,1.0,1.0));

      QString text(tr("no map available"));

      painter.drawText(QRectF(0,0,request.width, request.height),
                       text,
                       QTextOption(Qt::AlignCenter));

      return false;
    }
    QSize sz=finishedImage->size();


    osmscout::FillStyleRef unknownFillStyle;
    osmscout::Color        backgroundColor;

    styleConfig->GetUnknownFillStyle(projection,
                                     unknownFillStyle);

    if (unknownFillStyle.Valid()) {
      backgroundColor=unknownFillStyle->GetFillColor();
    }
    else {
        backgroundColor=osmscout::Color(0,0,0);
    }

    painter.fillRect(0,
                     0,
                     projection.GetWidth(),
                     projection.GetHeight(),
                     QColor::fromRgbF(backgroundColor.GetR(),
                                      backgroundColor.GetG(),
                                      backgroundColor.GetB(),
                                      backgroundColor.GetA()));

    sz*=zoomLevel;
    double x=0,y=0;
    QSize diffsz = finishedImage->size()-sz;
    x = diffsz.width()/2-
            dx;
    y = diffsz.height()/2-
            dy  ;
    QImage scaledImage = finishedImage->scaled(sz);

    painter.drawImage(x,y,scaledImage);
    return true;
}

bool DBThread::RenderMap(QPainter& painter,
                         const RenderMapRequest& request)
{
  QMutexLocker locker(&mutex);

  if (finishedImage==NULL || !styleConfig) {
    painter.fillRect(0,0,request.width,request.height,
                     QColor::fromRgbF(0.0,0.0,0.0,1.0));

    painter.setPen(QColor::fromRgbF(1.0,1.0,1.0,1.0));

    QString text(tr("no map available"));

    painter.drawText(QRectF(0,0,request.width,request.height),
                     text,
                     QTextOption(Qt::AlignCenter));

    return false;
  }

  projection.Set(finishedLon,finishedLat,
                 finishedAngle,
                 finishedMagnification,
                 finishedImage->width(),
                 finishedImage->height());

  osmscout::GeoBox boundingBox;

  projection.GetDimensions(boundingBox);

  double d=boundingBox.GetWidth()*2*M_PI/360;
  double scaleSize;
  size_t minScaleWidth=request.width/20;
  size_t maxScaleWidth=request.width/10;
  double scaleValue=d*180*60/M_PI*1852.216/(request.width/minScaleWidth);

  //std::cout << "1/10 screen (" << width/10 << " pixels) are: " << scaleValue << " meters" << std::endl;

  scaleValue=pow(10,floor(log10(scaleValue))+1);
  scaleSize=scaleValue/(d*180*60/M_PI*1852.216/request.width);

  if (scaleSize>minScaleWidth && scaleSize/2>minScaleWidth && scaleSize/2<=maxScaleWidth) {
    scaleValue=scaleValue/2;
    scaleSize=scaleSize/2;
  }
  else if (scaleSize>minScaleWidth && scaleSize/5>minScaleWidth && scaleSize/5<=maxScaleWidth) {
    scaleValue=scaleValue/5;
    scaleSize=scaleSize/5;
  }
  else if (scaleSize>minScaleWidth && scaleSize/10>minScaleWidth && scaleSize/10<=maxScaleWidth) {
    scaleValue=scaleValue/10;
    scaleSize=scaleSize/10;
  }

  //std::cout << "VisualScale: value: " << scaleValue << " pixel: " << scaleSize << std::endl;

  double dx=0;
  double dy=0;
  if (request.lon!=finishedLon || request.lat!=finishedLat) {
      double rx,ry,fx,fy;

      if (projection.GeoToPixel(request.lon,
                                request.lat,
                                rx,
                                ry) &&
          projection.GeoToPixel(finishedLon,
                                finishedLat,
                                fx,
                                fy)) {
          dx=fx-rx;
          dy=fy-ry;
      }
  }

  if ((dx!=0 ||
      dy!=0)||
         finishedMagnification.GetMagnification()>request.magnification.GetMagnification() ) {
    osmscout::FillStyleRef unknownFillStyle;
    osmscout::Color        backgroundColor;

    styleConfig->GetUnknownFillStyle(projection,
                                     unknownFillStyle);

    if (unknownFillStyle.Valid()) {
      backgroundColor=unknownFillStyle->GetFillColor();
    }
    else {
        backgroundColor=osmscout::Color(0,0,0);
    }

    painter.fillRect(0,
                     0,
                     projection.GetWidth(),
                     projection.GetHeight(),
                     QColor::fromRgbF(backgroundColor.GetR(),
                                      backgroundColor.GetG(),
                                      backgroundColor.GetB(),
                                      backgroundColor.GetA()));
  }

  if(finishedMagnification.GetMagnification()!=request.magnification.GetMagnification())
  {
    double zoomLevel = request.magnification.GetMagnification() / finishedMagnification.GetMagnification();
    QSize sz=finishedImage->size();
    sz*=zoomLevel;
    double x=0,y=0;
    QSize diffsz = finishedImage->size()-sz;
    x = diffsz.width()/2-
            dx;
    y = diffsz.height()/2-
            dy  ;
    painter.drawImage(x,y,finishedImage->scaled(sz));
  }
  else
    painter.drawImage(dx,dy,*finishedImage);


  return finishedImage->width()==(int)request.width &&
         finishedImage->height()==(int)request.height &&
         finishedLon==request.lon &&
         finishedLat==request.lat &&
         finishedAngle==request.angle &&
         finishedMagnification==request.magnification;
}

osmscout::TypeConfigRef DBThread::GetTypeConfig() const
{
  return database->GetTypeConfig();
}

bool DBThread::GetNodeByOffset(osmscout::FileOffset offset,
                               osmscout::NodeRef& node) const
{
  QMutexLocker locker(&mutex);

  return database->GetNodeByOffset(offset,node);
}

bool DBThread::GetAreaByOffset(osmscout::FileOffset offset,
                               osmscout::AreaRef& area) const
{
  QMutexLocker locker(&mutex);

  return database->GetAreaByOffset(offset,area);
}

bool DBThread::GetWayByOffset(osmscout::FileOffset offset,
                              osmscout::WayRef& way) const
{
  QMutexLocker locker(&mutex);

  return database->GetWayByOffset(offset,way);
}

bool DBThread::ResolveAdminRegionHierachie(const osmscout::AdminRegionRef& adminRegion,
                                           std::map<osmscout::FileOffset,osmscout::AdminRegionRef >& refs) const
{
  QMutexLocker locker(&mutex);

  return locationService->ResolveAdminRegionHierachie(adminRegion,
                                                      refs);
}

bool DBThread::SearchForLocations(const std::string& searchPattern,
                                  size_t limit,
                                  osmscout::LocationSearchResult& result) const
{
  QMutexLocker locker(&mutex);


  osmscout::LocationSearch search;

  search.limit=limit;
  if (!locationService->InitializeLocationSearchEntries(searchPattern,
                                                        search)) {
      return false;
  }

  return locationService->SearchForLocations(search,
                                             result);
}

bool DBThread::CalculateRoute(osmscout::Vehicle vehicle,
                              const osmscout::RoutingProfile& routingProfile,
                              const osmscout::ObjectFileRef& startObject,
                              size_t startNodeIndex,
                              const osmscout::ObjectFileRef targetObject,
                              size_t targetNodeIndex,
                              osmscout::RouteData& route)
{
  QMutexLocker locker(&mutex);

  if (!AssureRouter(vehicle)) {
    return false;
  }

  return router->CalculateRoute(routingProfile,
                                startObject,
                                startNodeIndex,
                                targetObject,
                                targetNodeIndex,
                                route);
}

bool DBThread::TransformRouteDataToRouteDescription(osmscout::Vehicle vehicle,
                                                    const osmscout::RoutingProfile& routingProfile,
                                                    const osmscout::RouteData& data,
                                                    osmscout::RouteDescription& description,
                                                    const std::string& start,
                                                    const std::string& target)
{
  QMutexLocker locker(&mutex);

  if (!AssureRouter(vehicle)) {
    return false;
  }

  if (!router->TransformRouteDataToRouteDescription(data,description)) {
    return false;
  }

  osmscout::TypeConfigRef typeConfig=router->GetTypeConfig();

  std::list<osmscout::RoutePostprocessor::PostprocessorRef> postprocessors;

  postprocessors.push_back(std::make_shared<osmscout::RoutePostprocessor::DistanceAndTimePostprocessor>());
  postprocessors.push_back(std::make_shared<osmscout::RoutePostprocessor::StartPostprocessor>(start));
  postprocessors.push_back(std::make_shared<osmscout::RoutePostprocessor::TargetPostprocessor>(target));
  postprocessors.push_back(std::make_shared<osmscout::RoutePostprocessor::WayNamePostprocessor>());
  postprocessors.push_back(std::make_shared<osmscout::RoutePostprocessor::CrossingWaysPostprocessor>());
  postprocessors.push_back(std::make_shared<osmscout::RoutePostprocessor::DirectionPostprocessor>());

  osmscout::RoutePostprocessor::InstructionPostprocessorRef instructionProcessor=std::make_shared<osmscout::RoutePostprocessor::InstructionPostprocessor>();

  instructionProcessor->AddMotorwayType(typeConfig->GetTypeInfo("highway_motorway"));
  instructionProcessor->AddMotorwayLinkType(typeConfig->GetTypeInfo("highway_motorway_link"));
  instructionProcessor->AddMotorwayType(typeConfig->GetTypeInfo("highway_motorway_trunk"));
  instructionProcessor->AddMotorwayType(typeConfig->GetTypeInfo("highway_trunk"));
  instructionProcessor->AddMotorwayLinkType(typeConfig->GetTypeInfo("highway_trunk_link"));
  instructionProcessor->AddMotorwayType(typeConfig->GetTypeInfo("highway_motorway_primary"));
  postprocessors.push_back(instructionProcessor);

  if (!routePostprocessor.PostprocessRouteDescription(description,
                                                      routingProfile,
                                                      *database,
                                                      postprocessors)) {
    return false;
  }

  return true;
}

bool DBThread::TransformRouteDataToWay(osmscout::Vehicle vehicle,
                                       const osmscout::RouteData& data,
                                       osmscout::Way& way)
{
  QMutexLocker locker(&mutex);

  if (!AssureRouter(vehicle)) {
    return false;
  }

  return router->TransformRouteDataToWay(data,way);
}

bool DBThread::TransformRouteDataToPoints(osmscout::Vehicle vehicle,
                                          const osmscout::RouteData& data,
                                          std::list<osmscout::Point>& points)
{
    QMutexLocker locker(&mutex);
    if (!AssureRouter(vehicle)) {
      return false;
    }

    return router->TransformRouteDataToPoints(data, points);
}


void DBThread::ClearRoute()
{
  QMutexLocker locker(&mutex);

  data.poiWays.clear();

  FreeMaps();

  emit Redraw();
}

void DBThread::AddRoute(const osmscout::Way& way)
{
  QMutexLocker locker(&mutex);

  data.poiWays.push_back(new osmscout::Way(way));

  FreeMaps();

  emit Redraw();
}

bool DBThread::GetClosestRoutableNode(const osmscout::ObjectFileRef& refObject,
                                      const osmscout::Vehicle& vehicle,
                                      double radius,
                                      osmscout::ObjectFileRef& object,
                                      size_t& nodeIndex)
{
  QMutexLocker locker(&mutex);
  if (!AssureRouter(vehicle)) {
    return false;
  }
  object.Invalidate();
  if (refObject.GetType()==osmscout::refNode) {
    osmscout::NodeRef node;

    if (!database->GetNodeByOffset(refObject.GetFileOffset(),
                                   node)) {
        std::cout<<node->GetCoords().GetLat()<<std::endl;
        std::cout<<node->GetCoords().GetLon()<<std::endl;

      return false;
    }
    return router->GetClosestRoutableNode(node->GetCoords().GetLat(),
                                          node->GetCoords().GetLon(),
                                          vehicle,
                                          radius,
                                          object,
                                          nodeIndex);
  }
  else if (refObject.GetType()==osmscout::refArea) {
    osmscout::AreaRef area;

    if (!database->GetAreaByOffset(refObject.GetFileOffset(),
                                   area)) {
      return false;
    }

    osmscout::GeoCoord center;

    area->GetCenter(center);

    return router->GetClosestRoutableNode(center.GetLat(),
                                          center.GetLon(),
                                          vehicle,
                                          radius,
                                          object,
                                          nodeIndex);
  }
  else if (refObject.GetType()==osmscout::refWay) {
    osmscout::WayRef way;

    if (!database->GetWayByOffset(refObject.GetFileOffset(),
                                  way)) {
      return false;
    }
    return router->GetClosestRoutableNode(way->nodes[0].GetLat(),
                                          way->nodes[0].GetLon(),
                                          vehicle,
                                          radius,
                                          object,
                                          nodeIndex);
  }
  else {
    return true;
  }
}

bool DBThread::GetClosestRoutableNode(double lat, double lon,
                                      const osmscout::Vehicle& vehicle,
                                      double radius,
                                      osmscout::ObjectFileRef& object,
                                      size_t& nodeIndex)
{
  QMutexLocker locker(&mutex);
  if (!AssureRouter(vehicle)) {
    return false;
  }
  object.Invalidate();
    return router->GetClosestRoutableNode(lat,
                                          lon,
                                          vehicle,
                                          radius,
                                          object,
                                          nodeIndex);

}


static DBThread* dbThreadInstance=NULL;

bool DBThread::InitializeInstance()
{
  if (dbThreadInstance!=NULL) {
    return false;
  }

  dbThreadInstance=new DBThread();

  return true;
}

DBThread* DBThread::GetInstance()
{
  return dbThreadInstance;
}

void DBThread::FreeInstance()
{
  delete dbThreadInstance;

  dbThreadInstance=NULL;
}

bool DBThread::IsOpened()
{
    return database->IsOpen();
}





