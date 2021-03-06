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

#include "RoutingModel.h"

#include <cmath>
#include <iostream>
#include <iomanip>
#include <osmscout/util/Geometry.h>
#include <Settings.h>

QString RoutingListModel::DistanceToString(double distance) const
{
  QSettings settings;
  bool metric = settings.value("metricSystem",(locale.measurementSystem()==QLocale::MetricSystem)).toBool();
  settings.setValue("metricSystem", metric);

  std::ostringstream stream;

  stream.setf(std::ios::fixed);

  if(metric)
  {
      if(distance>=1)
      {
          stream.precision(1);
          stream << distance << "km";
      }
      else
      {
          stream.precision(0);
          stream << distance*1000 << "m";
      }
  }
  else
  {
      stream.precision(1);
      stream << distance*0.621371 << "mi";
  }

  return QString::fromStdString(stream.str());
}

static QString TimeToString(double time)
{
  std::ostringstream stream;

  stream << (int)std::floor(time) << ":";

  time-=std::floor(time);

  stream << std::setfill('0') << std::setw(2) << (int)floor(60*time+0.5);


  return QString::fromStdString(stream.str());
}

QString RoutingListModel::MoveToTurnCommand(osmscout::RouteDescription::DirectionDescription::Move move)
{
  switch (move) {
  case osmscout::RouteDescription::DirectionDescription::sharpLeft:
    return tr("Turn sharp left");
  case osmscout::RouteDescription::DirectionDescription::left:
    return tr("Turn left");
  case osmscout::RouteDescription::DirectionDescription::slightlyLeft:
    return tr("Turn slightly left");
  case osmscout::RouteDescription::DirectionDescription::straightOn:
    return tr("Straight on");
  case osmscout::RouteDescription::DirectionDescription::slightlyRight:
    return tr("Turn slightly right");
  case osmscout::RouteDescription::DirectionDescription::right:
    return tr("Turn right");
  case osmscout::RouteDescription::DirectionDescription::sharpRight:
    return tr("Turn sharp right");
  }

  assert(false);

  return "???";
}

static QString MoveToTurnIcon(osmscout::RouteDescription::DirectionDescription::Move move)
{
  switch (move) {
  case osmscout::RouteDescription::DirectionDescription::sharpLeft:
    return "routeSharpLeft.svg";
  case osmscout::RouteDescription::DirectionDescription::left:
    return "routeLeft.svg";
  case osmscout::RouteDescription::DirectionDescription::slightlyLeft:
    return "routeSlightlyLeft.svg";
  case osmscout::RouteDescription::DirectionDescription::straightOn:
    return "routeStraight.svg";
  case osmscout::RouteDescription::DirectionDescription::slightlyRight:
    return "routeSlightlyRight.svg";
  case osmscout::RouteDescription::DirectionDescription::right:
    return "routeRight.svg";
  case osmscout::RouteDescription::DirectionDescription::sharpRight:
    return "routeSharpRight.svg";
  }

  assert(false);

  return "???";
}

static std::string CrossingWaysDescriptionToString(const osmscout::RouteDescription::CrossingWaysDescription& crossingWaysDescription)
{
  std::set<std::string>                          names;
  osmscout::RouteDescription::NameDescriptionRef originDescription=crossingWaysDescription.GetOriginDesccription();
  osmscout::RouteDescription::NameDescriptionRef targetDescription=crossingWaysDescription.GetTargetDesccription();

  if (originDescription.Valid()) {
    std::string nameString=originDescription->GetDescription();

    if (!nameString.empty()) {
      names.insert(nameString);
    }
  }

  if (targetDescription.Valid()) {
    std::string nameString=targetDescription->GetDescription();

    if (!nameString.empty()) {
      names.insert(nameString);
    }
  }

  for (std::list<osmscout::RouteDescription::NameDescriptionRef>::const_iterator name=crossingWaysDescription.GetDescriptions().begin();
      name!=crossingWaysDescription.GetDescriptions().end();
      ++name) {
    std::string nameString=(*name)->GetDescription();

    if (!nameString.empty()) {
      names.insert(nameString);
    }
  }

  if (names.size()>0) {
    std::ostringstream stream;

    stream << "<ul>";
    for (std::set<std::string>::const_iterator name=names.begin();
        name!=names.end();
        ++name) {
        /*
      if (name!=names.begin()) {
        stream << ", ";
      }*/
      stream << "<li>'" << *name << "'</li>";
    }
    stream << "</ul>";

    return stream.str();
  }
  else {
    return "";
  }
}

RouteStep::RouteStep()
{
    icon="route.svg";
    targetDistance=" ";
    targetTime=" ";
}

RouteStep::RouteStep(const RouteStep& other)
    : QObject(other.parent()),
      distance(other.distance),
      distanceDelta(other.distanceDelta),
      time(other.time),
      timeDelta(other.timeDelta),
      description(other.description),
      coord(other.coord),
      icon(other.icon),
      targetDistance(other.targetDistance),
      targetTime(other.targetTime),
      dTimeDelta(other.dTimeDelta),
      dDistanceDelta(other.dDistanceDelta)
{

}

RoutingListModel::RoutingListModel(QObject* parent)
: QAbstractListModel(parent)
{
    nextStepIndex = 0; //Start routing at begin of route
    // no code
}

RouteStep& RouteStep::operator=(const RouteStep& other)
{
    if (this!=&other) {
      setParent(other.parent());
      distance=other.distance;
      distanceDelta=other.distanceDelta;
      time=other.time;
      timeDelta=other.timeDelta;
      description=other.description;
      coord=other.coord;
      icon=other.icon;
      targetTime=other.targetTime;
      targetDistance=other.targetDistance;
      dTimeDelta=other.dTimeDelta;
      dDistanceDelta=other.dDistanceDelta;
    }
    return *this;
}

RoutingListModel::~RoutingListModel()
{
    route.routeSteps.clear();
}

void RoutingListModel::GetCarSpeedTable(std::map<std::string,double>& map)
{
  map["highway_motorway"]=110.0;
  map["highway_motorway_trunk"]=100.0;
  map["highway_motorway_primary"]=70.0;
  map["highway_motorway_link"]=60.0;
  map["highway_motorway_junction"]=60.0;
  map["highway_trunk"]=100.0;
  map["highway_trunk_link"]=60.0;
  map["highway_primary"]=70.0;
  map["highway_primary_link"]=60.0;
  map["highway_secondary"]=60.0;
  map["highway_secondary_link"]=50.0;
  map["highway_tertiary"]=55.0;
  map["highway_tertiary_link"]=55.0;
  map["highway_unclassified"]=50.0;
  map["highway_road"]=50.0;
  map["highway_residential"]=40.0;
  map["highway_roundabout"]=40.0;
  map["highway_living_street"]=10.0;
  map["highway_service"]=30.0;
}

void RoutingListModel::DumpStartDescription(const osmscout::RouteDescription::StartDescriptionRef& startDescription,
                                            const osmscout::RouteDescription::NameDescriptionRef& nameDescription)
{
  RouteStep startAt;

  startAt.description=tr("Start at")+" '"+QString::fromUtf8(startDescription->GetDescription().c_str())+"'";
  route.routeSteps.push_back(startAt);

  if (nameDescription.Valid() &&
      nameDescription->HasName()) {
    RouteStep driveAlong;

    driveAlong.description=tr("Drive along")+" '"+QString::fromUtf8(nameDescription->GetDescription().c_str())+"'";
    route.routeSteps.push_back(driveAlong);
  }
}

void RoutingListModel::DumpTargetDescription(const osmscout::RouteDescription::TargetDescriptionRef& targetDescription)
{
  RouteStep targetReached;
  targetReached.icon = "routeFinish.svg";
  targetReached.description=tr("Target reached")+" '"+QString::fromUtf8(targetDescription->GetDescription().c_str())+"'";
  route.routeSteps.push_back(targetReached);
}

void RoutingListModel::DumpTurnDescription(const osmscout::RouteDescription::TurnDescriptionRef& /*turnDescription*/,
                                           const osmscout::RouteDescription::CrossingWaysDescriptionRef& crossingWaysDescription,
                                           const osmscout::RouteDescription::DirectionDescriptionRef& directionDescription,
                                           const osmscout::RouteDescription::NameDescriptionRef& nameDescription)
{
  RouteStep   turn;
  std::string crossingWaysString;

  if (crossingWaysDescription.Valid()) {
    crossingWaysString=CrossingWaysDescriptionToString(crossingWaysDescription);
  }
  if(directionDescription.Valid()) {
      turn.icon=MoveToTurnIcon(directionDescription->GetCurve());
  }
  if (!crossingWaysString.empty()) {
    turn.description=tr("At crossing")+" "+QString::fromUtf8(crossingWaysString.c_str())+"";
  }
  if (directionDescription.Valid()) {
    turn.description+=MoveToTurnCommand(directionDescription->GetCurve());
  }
  else {
    turn.description+=tr("Turn");
  }

  if (nameDescription.Valid() &&
      nameDescription->HasName()) {
    turn.description+=" "+tr("into")+" '"+QString::fromUtf8(nameDescription->GetDescription().c_str())+"'";
  }

  route.routeSteps.push_back(turn);
}

void RoutingListModel::DumpRoundaboutEnterDescription(const osmscout::RouteDescription::RoundaboutEnterDescriptionRef& /*roundaboutEnterDescription*/,
                                                      const osmscout::RouteDescription::CrossingWaysDescriptionRef& crossingWaysDescription)
{
  RouteStep   enter;
  std::string crossingWaysString;

  if (crossingWaysDescription.Valid()) {
    crossingWaysString=CrossingWaysDescriptionToString(crossingWaysDescription);
  }

  if (!crossingWaysString.empty()) {
    enter.description=tr("At crossing")+" "+QString::fromUtf8(crossingWaysString.c_str())+"";
  }


  enter.description+=tr("Enter roundabout");

  route.routeSteps.push_back(enter);
}

void RoutingListModel::DumpRoundaboutLeaveDescription(const osmscout::RouteDescription::RoundaboutLeaveDescriptionRef& roundaboutLeaveDescription,
                                                      const osmscout::RouteDescription::NameDescriptionRef& nameDescription)
{
  RouteStep leave;

  leave.description=tr("Leave roundabout")+" (";
  leave.description+=QString::number(roundaboutLeaveDescription->GetExitCount());
  leave.description+=". "+tr("exit")+")";
  switch(roundaboutLeaveDescription->GetExitCount())
  {
    case 1:
      leave.icon = "routeRoundabout1.svg";
      break;
    case 2:
      leave.icon = "routeRoundabout2.svg";
      break;
    case 3:
      leave.icon = "routeRoundabout3.svg";
      break;
    case 4:
      leave.icon = "routeRoundabout4.svg";
      break;
    case 5:
      leave.icon = "routeRoundabout5.svg";
      break;
    default:
      leave.icon = "routeRoundabout4.svg";

  }

  if (nameDescription.Valid() &&
      nameDescription->HasName()) {
    leave.description+=" "+tr("into street")+" '";
    leave.description+=QString::fromUtf8(nameDescription->GetDescription().c_str());
    leave.description+="'";
  }

  route.routeSteps.push_back(leave);
}

void RoutingListModel::DumpMotorwayEnterDescription(const osmscout::RouteDescription::MotorwayEnterDescriptionRef& motorwayEnterDescription,
                                                    const osmscout::RouteDescription::CrossingWaysDescriptionRef& crossingWaysDescription)
{
  RouteStep   enter;
  std::string crossingWaysString;

  if (crossingWaysDescription.Valid()) {
    crossingWaysString=CrossingWaysDescriptionToString(crossingWaysDescription);
  }

  if (!crossingWaysString.empty()) {
    enter.description=tr("At crossing")+" "+QString::fromUtf8(crossingWaysString.c_str());
  }
  enter.icon = "routeMotorwayEnter.svg";
  enter.description+=tr("Enter motorway");

  if (motorwayEnterDescription->GetToDescription().Valid() &&
      motorwayEnterDescription->GetToDescription()->HasName()) {
    enter.description+=" '";
    enter.description+=QString::fromUtf8(motorwayEnterDescription->GetToDescription()->GetDescription().c_str());
    enter.description+="'";
  }

  route.routeSteps.push_back(enter);
}

void RoutingListModel::DumpMotorwayChangeDescription(const osmscout::RouteDescription::MotorwayChangeDescriptionRef& motorwayChangeDescription)
{
  RouteStep change;
  change.description=tr("Change motorway");

  if (motorwayChangeDescription->GetFromDescription().Valid() &&
      motorwayChangeDescription->GetFromDescription()->HasName()) {
    change.description+=" "+tr("from")+" '";
    change.description+=QString::fromUtf8(motorwayChangeDescription->GetFromDescription()->GetDescription().c_str());
    change.description+="'";
  }

  if (motorwayChangeDescription->GetToDescription().Valid() &&
      motorwayChangeDescription->GetToDescription()->HasName()) {
    change.description+=" "+tr("to")+" '";
    change.description+=QString::fromUtf8(motorwayChangeDescription->GetToDescription()->GetDescription().c_str());
    change.description+="'";
  }

  route.routeSteps.push_back(change);
}

void RoutingListModel::DumpMotorwayLeaveDescription(const osmscout::RouteDescription::MotorwayLeaveDescriptionRef& motorwayLeaveDescription,
                                                    const osmscout::RouteDescription::DirectionDescriptionRef& directionDescription,
                                                    const osmscout::RouteDescription::NameDescriptionRef& nameDescription)
{
  RouteStep leave;

  leave.description=tr("Leave motorway");
  leave.icon="routeMotorwayLeave.svg";

  if (motorwayLeaveDescription->GetFromDescription().Valid() &&
      motorwayLeaveDescription->GetFromDescription()->HasName()) {
    leave.description+=" '";
    leave.description+=QString::fromUtf8(motorwayLeaveDescription->GetFromDescription()->GetDescription().c_str());
    leave.description+="'";
  }

  if (directionDescription.Valid() &&
      directionDescription->GetCurve()!=osmscout::RouteDescription::DirectionDescription::slightlyLeft &&
      directionDescription->GetCurve()!=osmscout::RouteDescription::DirectionDescription::straightOn &&
      directionDescription->GetCurve()!=osmscout::RouteDescription::DirectionDescription::slightlyRight) {
    leave.description+=MoveToTurnCommand(directionDescription->GetCurve());
  }

  if (nameDescription.Valid() &&
      nameDescription->HasName()) {
    leave.description+=" "+tr("into")+" '";
    leave.description+=QString::fromUtf8(nameDescription->GetDescription().c_str());
    leave.description+="'";
  }

  route.routeSteps.push_back(leave);
}

void RoutingListModel::DumpNameChangedDescription(const osmscout::RouteDescription::NameChangedDescriptionRef& nameChangedDescription)
{
  RouteStep changed;

  changed.description="";

  if (nameChangedDescription->GetOriginDesccription().Valid()) {
    changed.description+=tr("Way changes name")+"<br/>";
    changed.description+=tr("from")+" '";
    changed.description+=QString::fromUtf8(nameChangedDescription->GetOriginDesccription()->GetDescription().c_str());
    changed.description+="'<br/>";
    changed.description+=" "+tr("to")+" '";
    changed.description+=QString::fromUtf8(nameChangedDescription->GetTargetDesccription()->GetDescription().c_str());
    changed.description+="'";
  }
  else {
    changed.description+=tr("Way changes name")+"<br/>";
    changed.description+=tr("to")+" '";
    changed.description+=QString::fromUtf8(nameChangedDescription->GetTargetDesccription()->GetDescription().c_str());
    changed.description+="'";
  }

  route.routeSteps.push_back(changed);
}

void RoutingListModel::setStartAndTarget(Location* start,
                                         Location* target)
{
  nextStepIndex = 0; //Start routing at begin of route
  beginResetModel();
  route.routeSteps.clear();
  qDebug() << "Routing from '" << start->getName().toLocal8Bit().data() << "' to '" << target->getName().toLocal8Bit().data() << "'";
  osmscout::TypeConfigRef             typeConfig=DBThread::GetInstance()->GetTypeConfig();
  osmscout::FastestPathRoutingProfile routingProfile(typeConfig);
  osmscout::Way                       routeWay;
  QSettings settings;
  osmscout::Vehicle vehicle=(osmscout::Vehicle)settings.value("routing/vehicle",osmscout::vehicleCar).toUInt();;

  if (vehicle==osmscout::vehicleFoot) {
    routingProfile.ParametrizeForFoot(*typeConfig,
                                      5.0);
  }
  else if (vehicle==osmscout::vehicleBicycle) {
    routingProfile.ParametrizeForBicycle(*typeConfig,
                                         20.0);
  }
  else /* car */ {
    std::map<std::string,double> speedMap;

    GetCarSpeedTable(speedMap);

    routingProfile.ParametrizeForCar(*typeConfig,
                                     speedMap,
                                     160.0);
  }
  osmscout::ObjectFileRef startObject;
  size_t                  startNodeIndex;

  osmscout::ObjectFileRef targetObject;
  size_t                  targetNodeIndex;

  if(start->getReferences().size()>0)
  {
      if (!DBThread::GetInstance()->GetClosestRoutableNode(start->getReferences().front(),
                                                           vehicle,
                                                           500,
                                                           startObject,
                                                           startNodeIndex)) {
        std::cerr << "There was an error while routing!" << std::endl;
      }
  }
  else
  {
       if (!DBThread::GetInstance()->GetClosestRoutableNode(start->getCoord().GetLat(),
                                                            start->getCoord().GetLon(),
                                                            vehicle,
                                                            500,
                                                            startObject,
                                                            startNodeIndex)) {
         std::cerr << "There was an error while routing!" << std::endl;
       }
  }

  if (!startObject.Valid()) {
    std::cerr << "Cannot find a routing node close to the start location" << std::endl;
  }
  if(target->getReferences().size()>0)
  {
      if (!DBThread::GetInstance()->GetClosestRoutableNode(target->getReferences().front(),
                                                           vehicle,
                                                           500,
                                                           targetObject,
                                                           targetNodeIndex)) {
        std::cerr << "There was an error while routing!" << std::endl;
      }
  }
  else
  {
      if (!DBThread::GetInstance()->GetClosestRoutableNode(target->getCoord().GetLat(),
                                                           target->getCoord().GetLon(),
                                                           vehicle,
                                                           500,
                                                           targetObject,
                                                           targetNodeIndex)) {
        std::cerr << "There was an error while routing!" << std::endl;
      }
  }

  if (!targetObject.Valid()) {
    std::cerr << "Cannot find a routing node close to the target location" << std::endl;
  }
  if (!DBThread::GetInstance()->CalculateRoute(vehicle,
                                               routingProfile,
                                               startObject,
                                               startNodeIndex,
                                               targetObject,
                                               targetNodeIndex,
                                               route.routeData)) {
    std::cerr << "There was an error while routing!" << std::endl;
    return;
  }

  std::cout << "Route calculated" << std::endl;

  DBThread::GetInstance()->TransformRouteDataToRouteDescription(vehicle,
                                                                routingProfile,
                                                                route.routeData,
                                                                route.routeDescription,
                                                                start->getName().toUtf8().constData(),
                                                                target->getName().toUtf8().constData());

  std::cout << "Route transformed" << std::endl;

  size_t roundaboutCrossingCounter=0;
  int    lastStepIndex=-1;

  std::list<osmscout::RouteDescription::Node>::const_iterator prevNode=route.routeDescription.Nodes().end();
  for (std::list<osmscout::RouteDescription::Node>::const_iterator node=route.routeDescription.Nodes().begin();
       node!=route.routeDescription.Nodes().end();
       ++node) {
    osmscout::RouteDescription::DescriptionRef                 desc;
    osmscout::RouteDescription::NameDescriptionRef             nameDescription;
    osmscout::RouteDescription::DirectionDescriptionRef        directionDescription;
    osmscout::RouteDescription::NameChangedDescriptionRef      nameChangedDescription;
    osmscout::RouteDescription::CrossingWaysDescriptionRef     crossingWaysDescription;

    osmscout::RouteDescription::StartDescriptionRef            startDescription;
    osmscout::RouteDescription::TargetDescriptionRef           targetDescription;
    osmscout::RouteDescription::TurnDescriptionRef             turnDescription;
    osmscout::RouteDescription::RoundaboutEnterDescriptionRef  roundaboutEnterDescription;
    osmscout::RouteDescription::RoundaboutLeaveDescriptionRef  roundaboutLeaveDescription;
    osmscout::RouteDescription::MotorwayEnterDescriptionRef    motorwayEnterDescription;
    osmscout::RouteDescription::MotorwayChangeDescriptionRef   motorwayChangeDescription;
    osmscout::RouteDescription::MotorwayLeaveDescriptionRef    motorwayLeaveDescription;

    desc=node->GetDescription(osmscout::RouteDescription::WAY_NAME_DESC);
    if (desc.Valid()) {
      nameDescription=dynamic_cast<osmscout::RouteDescription::NameDescription*>(desc.Get());
    }

    desc=node->GetDescription(osmscout::RouteDescription::DIRECTION_DESC);
    if (desc.Valid()) {
      directionDescription=dynamic_cast<osmscout::RouteDescription::DirectionDescription*>(desc.Get());
    }

    desc=node->GetDescription(osmscout::RouteDescription::WAY_NAME_CHANGED_DESC);
    if (desc.Valid()) {
      nameChangedDescription=dynamic_cast<osmscout::RouteDescription::NameChangedDescription*>(desc.Get());
    }

    desc=node->GetDescription(osmscout::RouteDescription::CROSSING_WAYS_DESC);
    if (desc.Valid()) {
      crossingWaysDescription=dynamic_cast<osmscout::RouteDescription::CrossingWaysDescription*>(desc.Get());
    }

    desc=node->GetDescription(osmscout::RouteDescription::NODE_START_DESC);
    if (desc.Valid()) {
      startDescription=dynamic_cast<osmscout::RouteDescription::StartDescription*>(desc.Get());
    }

    desc=node->GetDescription(osmscout::RouteDescription::NODE_TARGET_DESC);
    if (desc.Valid()) {
      targetDescription=dynamic_cast<osmscout::RouteDescription::TargetDescription*>(desc.Get());
    }

    desc=node->GetDescription(osmscout::RouteDescription::TURN_DESC);
    if (desc.Valid()) {
      turnDescription=dynamic_cast<osmscout::RouteDescription::TurnDescription*>(desc.Get());
    }

    desc=node->GetDescription(osmscout::RouteDescription::ROUNDABOUT_ENTER_DESC);
    if (desc.Valid()) {
      roundaboutEnterDescription=dynamic_cast<osmscout::RouteDescription::RoundaboutEnterDescription*>(desc.Get());
    }

    desc=node->GetDescription(osmscout::RouteDescription::ROUNDABOUT_LEAVE_DESC);
    if (desc.Valid()) {
      roundaboutLeaveDescription=dynamic_cast<osmscout::RouteDescription::RoundaboutLeaveDescription*>(desc.Get());
    }

    desc=node->GetDescription(osmscout::RouteDescription::MOTORWAY_ENTER_DESC);
    if (desc.Valid()) {
      motorwayEnterDescription=dynamic_cast<osmscout::RouteDescription::MotorwayEnterDescription*>(desc.Get());
    }

    desc=node->GetDescription(osmscout::RouteDescription::MOTORWAY_CHANGE_DESC);
    if (desc.Valid()) {
      motorwayChangeDescription=dynamic_cast<osmscout::RouteDescription::MotorwayChangeDescription*>(desc.Get());
    }

    desc=node->GetDescription(osmscout::RouteDescription::MOTORWAY_LEAVE_DESC);
    if (desc.Valid()) {
      motorwayLeaveDescription=dynamic_cast<osmscout::RouteDescription::MotorwayLeaveDescription*>(desc.Get());
    }

    if (crossingWaysDescription.Valid() &&
        roundaboutCrossingCounter>0 &&
        crossingWaysDescription->GetExitCount()>1) {
      roundaboutCrossingCounter+=crossingWaysDescription->GetExitCount()-1;
    }

    if (startDescription.Valid()) {
      DumpStartDescription(startDescription,
                           nameDescription);
    }
    else if (targetDescription.Valid()) {
      DumpTargetDescription(targetDescription);
    }
    else if (turnDescription.Valid()) {
      DumpTurnDescription(turnDescription,
                          crossingWaysDescription,
                          directionDescription,
                          nameDescription);
    }
    else if (roundaboutEnterDescription.Valid()) {
      DumpRoundaboutEnterDescription(roundaboutEnterDescription,
                                     crossingWaysDescription);

      roundaboutCrossingCounter=1;
    }
    else if (roundaboutLeaveDescription.Valid()) {
      DumpRoundaboutLeaveDescription(roundaboutLeaveDescription,
                                     nameDescription);

      roundaboutCrossingCounter=0;
    }
    else if (motorwayEnterDescription.Valid()) {
      DumpMotorwayEnterDescription(motorwayEnterDescription,
                                   crossingWaysDescription);
    }
    else if (motorwayChangeDescription.Valid()) {
      DumpMotorwayChangeDescription(motorwayChangeDescription);
    }
    else if (motorwayLeaveDescription.Valid()) {
      DumpMotorwayLeaveDescription(motorwayLeaveDescription,
                                   directionDescription,
                                   nameDescription);
    }
    else if (nameChangedDescription.Valid()) {
      DumpNameChangedDescription(nameChangedDescription);
    }
    else {
      continue;
    }

    int currentStepIndex;

    if (lastStepIndex>=0) {
        currentStepIndex=lastStepIndex+1;
    }
    else {
        currentStepIndex=0;
    }
    route.routeSteps[currentStepIndex].coord=node->GetLocation();
    if (currentStepIndex>=0) {
      route.routeSteps[currentStepIndex].distance=DistanceToString(node->GetDistance());
      route.routeSteps[currentStepIndex].time=TimeToString(node->GetTime());

      if (prevNode!=route.routeDescription.Nodes().end() &&
          node->GetDistance()-prevNode->GetDistance()!=0.0) {
        route.routeSteps[currentStepIndex].distanceDelta=DistanceToString(node->GetDistance()-prevNode->GetDistance());
        route.routeSteps[currentStepIndex].dDistanceDelta=node->GetDistance()-prevNode->GetDistance();
      }

      if (prevNode!=route.routeDescription.Nodes().end() &&
          node->GetTime()-prevNode->GetTime()!=0.0) {
        route.routeSteps[currentStepIndex].timeDelta=TimeToString(node->GetTime()-prevNode->GetTime());
        route.routeSteps[currentStepIndex].dTimeDelta=node->GetTime()-prevNode->GetTime();
      }
    }

    lastStepIndex=route.routeSteps.size()-1;

    prevNode=node;
  }
  double totalTime=0;
  double totalDistance=0;
  for(int i=route.routeSteps.size()-1; i>=0; i--)
  {
      totalTime += route.routeSteps[i].dTimeDelta;
      totalDistance += route.routeSteps[i].dDistanceDelta;
      route.routeSteps[i].targetTime = TimeToString(totalTime);
      route.routeSteps[i].targetDistance = DistanceToString(totalDistance);
  }

  if (DBThread::GetInstance()->TransformRouteDataToWay(vehicle,
                                                       route.routeData,
                                                       routeWay)) {
    DBThread::GetInstance()->ClearRoute();
    DBThread::GetInstance()->AddRoute(routeWay);
  }
  else {
    std::cerr << "Error while transforming route" << std::endl;
  }

  endResetModel();
}

int RoutingListModel::rowCount(const QModelIndex& ) const
{
    return route.routeSteps.size();
}

QVariant RoutingListModel::data(const QModelIndex &index, int role) const
{
    if(index.row() < 0 || index.row() >= route.routeSteps.size()) {
        return QVariant();
    }

    RouteStep step=route.routeSteps.at(index.row());

    switch (role) {
    case Qt::DisplayRole:
    case LabelRole:
        return step.getDescription();
    default:
        break;
    }

    return QVariant();
}

Qt::ItemFlags RoutingListModel::flags(const QModelIndex &index) const
{
    if(!index.isValid()) {
        return Qt::ItemIsEnabled;
    }

    return QAbstractListModel::flags(index) | Qt::ItemIsEnabled | Qt::ItemIsSelectable;
}

QHash<int, QByteArray> RoutingListModel::roleNames() const
{
    QHash<int, QByteArray> roles=QAbstractListModel::roleNames();

    roles[LabelRole]="label";

    return roles;
}

RouteStep* RoutingListModel::get(int row) const
{
    if(row < 0 || row >= route.routeSteps.size()) {
        return NULL;
    }

    RouteStep step=route.routeSteps.at(row);

    return new RouteStep(step);
}


RouteStep* RoutingListModel::getNext(double lat, double lon)
{
    awayFromRoute = false;
    if(route.routeSteps.size()<=0)
    {
        RouteStep* step = new RouteStep();
        step->description = tr("No Route data available");
        step->currentDistance="";
        step->dCurrentDistance=0;
        step->index = 0;
        return step;
    }

    double closestPoint = 7000; //more than largest possible distance
    int closestIndex = 0; //start position.
    nextStepIndex = 0;
    for(int i=0; i<(route.routeSteps.size()-1); i++)
    {
        //double d = osmscout::GetSphericalDistance(lon, lat, route.routeSteps[i].coord.GetLon(), route.routeSteps[i].coord.GetLat());
        //calculate distance between two instruction points of the rout, to determine where we are (which instruction to show)
        double r, qx, qy;
        double d = osmscout::distanceToSegment(lon, lat,route.routeSteps[i].coord.GetLon(), route.routeSteps[i].coord.GetLat(),route.routeSteps[i+1].coord.GetLon(), route.routeSteps[i+1].coord.GetLat(), r, qx, qy)*(6371.01/360)*2*M_PI;

        if(d<closestPoint)
        {
            closestIndex=i;
            closestPoint=d;
            nextStepIndex = i+1;

        }
    }
    while(route.routeSteps[nextStepIndex].icon=="route.svg") //routeSteps without icon are not necessary to display, let's take the next one
    {
        if((nextStepIndex+1)<route.routeSteps.size())
        {
            nextStepIndex++;
        }
        else
        {
            break;
        }
    }
    /**
     * Check whether we are still on the track...
     */
    DBThread* dbThread = DBThread::GetInstance();
    std::list<osmscout::Point> points;
    std::list<osmscout::Point>::iterator lastPoint=points.begin();
    QSettings settings;
    osmscout::Vehicle vehicle=(osmscout::Vehicle)settings.value("routing/vehicle",osmscout::vehicleCar).toUInt();;
    dbThread->TransformRouteDataToPoints(vehicle, route.routeData, points);
    double closestDistToSegment=7000;
    for(std::list<osmscout::Point>::iterator point = points.begin(); point!=points.end(); ++point)
    {
        if(lastPoint->GetLat()==point->GetLat()&&lastPoint->GetLon()==point->GetLon())
            continue; //for the first step, coordinates are equal.
        double r, qx, qy;
        double distToSegment = osmscout::distanceToSegment(lon, lat, lastPoint->GetLon(), lastPoint->GetLat(), point->GetLon(), point->GetLat(), r, qx, qy)*(6371.01/360)*2*M_PI;
        if(distToSegment<closestDistToSegment)
        {
            closestDistToSegment = distToSegment;
        }
        lastPoint = point;
    }

    if(closestDistToSegment > 0.05)
    {
        awayCounter++;
        if(awayCounter>10)
        {
            awayCounter = 0;
            RouteStep* step = new RouteStep();
            step->description = tr("Recalulating route...");
            step->currentDistance="";
            step->dCurrentDistance=0;
            awayFromRoute = true;
            step->index = 0;
            return step;
        }
    }
    else
    {
        awayCounter = 0;
    }

    RouteStep* step = new RouteStep(route.routeSteps[nextStepIndex]);
    step->index = nextStepIndex;
    step->dCurrentDistance=osmscout::GetSphericalDistance(lon, lat, step->coord.GetLon(), step->coord.GetLat());
    step->currentDistance=DistanceToString(step->dCurrentDistance);

    return step;


}
