#ifndef ROUTINGMODEL_H
#define ROUTINGMODEL_H

/*
 OSMScout - a Qt backend for libosmscout and libosmscout-map
 Copyright (C) 2014  Tim Teulings

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

#include <map>

#include <QObject>
#include <QAbstractListModel>

#include <osmscout/Location.h>
#include <osmscout/Route.h>

#include "SearchLocationModel.h"
#include "DBThread.h"

class RouteStep : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString distance READ getDistance)
    Q_PROPERTY(QString distanceDelta READ getDistanceDelta)
    Q_PROPERTY(QString currentDistance READ getCurrentDistance)
    Q_PROPERTY(QString time READ getTime)
    Q_PROPERTY(QString timeDelta READ getTimeDelta)
    Q_PROPERTY(QString description READ getDescription)
    Q_PROPERTY(QString icon READ getIcon)
    Q_PROPERTY(QString targetTime READ getTargetTime)
    Q_PROPERTY(QString targetDistance READ getTargetDistance)
    Q_PROPERTY(int     index READ getIndex)
    Q_PROPERTY(double  dCurrentDistance READ getDCurrentDistance)


public:
  QString distance;
  QString distanceDelta;
  QString time;
  QString timeDelta;
  QString description;
  QString icon;
  osmscout::GeoCoord coord;
  QString currentDistance;
  QString targetTime;
  QString targetDistance;
  double dTimeDelta;
  double dDistanceDelta;
  double dCurrentDistance;
  int index;


public:
  RouteStep();
  RouteStep(const RouteStep& other);

  RouteStep& operator=(const RouteStep& other);

  QString getDistance() const
  {
      return distance;
  }

  QString getDistanceDelta() const
  {
      return distanceDelta;
  }

  QString getTargetDistance() const
  {
      return targetDistance;
  }

  QString getCurrentDistance() const
  {
      return currentDistance;
  }

  QString getTime() const
  {
      return time;
  }

  QString getTimeDelta() const
  {
      return timeDelta;
  }

  QString getTargetTime() const
  {
      return targetTime;
  }

  QString getDescription() const
  {
      return description;
  }

  QString getIcon() const
  {
      return icon;
  }

  int getIndex() const
  {
      return index;
  }

  double getDCurrentDistance() const
  {
      return dCurrentDistance;
  }
};

class RoutingListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount)

public slots:
    void setStartAndTarget(Location* start,
                           Location* target);

    QString DistanceToString(double distance) const;


private:
    struct RouteSelection
    {
      osmscout::RouteData        routeData;
      osmscout::RouteDescription routeDescription;
      QList<RouteStep>           routeSteps;
    };

    QLocale locale;

    RouteSelection route;
    int nextStepIndex;
    bool awayFromRoute;
    int awayCounter;

public:
    enum Roles {
        LabelRole = Qt::UserRole
    };

private:
    void GetCarSpeedTable(std::map<std::string,double>& map);

    void DumpStartDescription(const osmscout::RouteDescription::StartDescriptionRef& startDescription,
                              const osmscout::RouteDescription::NameDescriptionRef& nameDescription);
    void DumpTargetDescription(const osmscout::RouteDescription::TargetDescriptionRef& targetDescription);
    void DumpTurnDescription(const osmscout::RouteDescription::TurnDescriptionRef& turnDescription,
                             const osmscout::RouteDescription::CrossingWaysDescriptionRef& crossingWaysDescription,
                             const osmscout::RouteDescription::DirectionDescriptionRef& directionDescription,
                             const osmscout::RouteDescription::NameDescriptionRef& nameDescription);
    void DumpRoundaboutEnterDescription(const osmscout::RouteDescription::RoundaboutEnterDescriptionRef& roundaboutEnterDescription,
                                        const osmscout::RouteDescription::CrossingWaysDescriptionRef& crossingWaysDescription);
    void DumpRoundaboutLeaveDescription(const osmscout::RouteDescription::RoundaboutLeaveDescriptionRef& roundaboutLeaveDescription,
                                        const osmscout::RouteDescription::NameDescriptionRef& nameDescription);
    void DumpMotorwayEnterDescription(const osmscout::RouteDescription::MotorwayEnterDescriptionRef& motorwayEnterDescription,
                                      const osmscout::RouteDescription::CrossingWaysDescriptionRef& crossingWaysDescription);
    void DumpMotorwayChangeDescription(const osmscout::RouteDescription::MotorwayChangeDescriptionRef& motorwayChangeDescription);
    void DumpMotorwayLeaveDescription(const osmscout::RouteDescription::MotorwayLeaveDescriptionRef& motorwayLeaveDescription,
                                      const osmscout::RouteDescription::DirectionDescriptionRef& directionDescription,
                                      const osmscout::RouteDescription::NameDescriptionRef& nameDescription);
    void DumpNameChangedDescription(const osmscout::RouteDescription::NameChangedDescriptionRef& nameChangedDescription);

    QString MoveToTurnCommand(osmscout::RouteDescription::DirectionDescription::Move move);

public:
    RoutingListModel(QObject* parent = 0);
    ~RoutingListModel();

    QVariant data(const QModelIndex &index, int role) const;

    int rowCount(const QModelIndex &parent = QModelIndex()) const;

    Qt::ItemFlags flags(const QModelIndex &index) const;

    QHash<int, QByteArray> roleNames() const;

    Q_INVOKABLE RouteStep* get(int row) const;
    Q_INVOKABLE RouteStep* getNext(double lat, double lon);
    Q_INVOKABLE bool       getAwayFromRoute(void){return awayFromRoute;}
};

#endif
