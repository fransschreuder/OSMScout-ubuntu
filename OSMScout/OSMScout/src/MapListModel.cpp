#include "MapListModel.h"

MapListItem::MapListItem( const QString& name,
             const QString& path,
             QObject* parent): QObject(parent)
{
    m_name = name;
    m_path = path;
}

MapListItem::~MapListItem()
{

}


QString MapListItem::getName() const
{
    return m_name;
}

QString MapListItem::getPath() const
{
    return m_path;
}

////////////////////////
MapListModel::MapListModel(QObject* parent): QAbstractListModel(parent)
{
    refreshItems();
}

bool MapListModel::refreshItems()
{
    beginResetModel();
    mapListItems.clear();

    QStringList list_files = DBThread::GetInstance()->findValidMapDirs();

    for(int j=0; j<list_files.size(); j++)
    {
        QString name = list_files[j].split("/").back();
        MapListItem* item = new MapListItem(name, list_files[j]);
        //beginInsertRows(QModelIndex(), j, j);
        mapListItems.append(item);
        //endInsertRows();
    }
    qDebug()<<"Refreshed Items";
    if(mapListItems.size()==0)mapListItems.append(new MapListItem("",""));
    endResetModel();
    return true;
}

MapListModel::~MapListModel()
{
    for (QList<MapListItem*>::iterator item=mapListItems.begin();
         item!=mapListItems.end();
         ++item) {
        delete *item;
    }

    mapListItems.clear();
}

QVariant MapListModel::data(const QModelIndex &index, int role) const
{
    if(index.row() < 0 || index.row() >= mapListItems.size()) {
        return QVariant();
    }

    MapListItem* item = mapListItems.at(index.row());
    switch (role) {
    case Qt::DisplayRole:
    case NameRole:
        return item->getName();
    case PathRole:
        return item->getPath();
    default:
        break;
    }

    return QVariant();
}

int MapListModel::rowCount(const QModelIndex &parent) const
{
    return mapListItems.size();
}

Qt::ItemFlags MapListModel::flags(const QModelIndex &index) const
{
    if(!index.isValid()) {
        return Qt::ItemIsEnabled;
    }

    return QAbstractListModel::flags(index) | Qt::ItemIsEnabled | Qt::ItemIsSelectable;
}

QHash<int, QByteArray> MapListModel::roleNames() const
{
    QHash<int, QByteArray> roles=QAbstractListModel::roleNames();

    roles[PathRole]="path";
    roles[NameRole]="name";

    return roles;
}

QString MapListModel::get(int row) const
{
    return mapListItems.at(row)->getName();
}

bool removeDir(const QString & dirName)
{
    bool result = true;
    QDir dir(dirName);

    if (dir.exists(dirName)) {
        Q_FOREACH(QFileInfo info, dir.entryInfoList(QDir::NoDotAndDotDot | QDir::System | QDir::Hidden  | QDir::AllDirs | QDir::Files, QDir::DirsFirst)) {
            if (info.isDir()) {
                result = removeDir(info.absoluteFilePath());
            }
            else {
                result = QFile::remove(info.absoluteFilePath());
            }

            if (!result) {
                return result;
            }
        }
        result = dir.rmdir(dirName);
    }
    return result;
}

bool MapListModel::deleteItem(int row)
{
    if(mapListItems.size()>row)
    {
        qDebug()<<"Removing dir"<<mapListItems[row]->getPath();
        if(removeDir(mapListItems[row]->getPath()))
        {
            beginRemoveRows(QModelIndex(), row, row);
            mapListItems.removeAt(row);
            endRemoveRows();
            return true;
        }
        else
            return false;
    }
    else
        return false;
}

QString MapListModel::getFreeSpace()
{
    QString folder = getPreferredDownloadDir().split("/Maps")[0];
    QDir dir(folder);
    QStorageInfo si(dir);
    double bytes = (double) si.bytesAvailable();
    QString freeString;
    if(bytes<1024)
    {
        freeString = QString::number(bytes/(1),'f', 2)+" "+tr("bytes");
    }
    else if(bytes>=1024&&bytes<(1024*1024))
    {
        freeString = QString::number(bytes/(1024),'f', 2)+" "+tr("kB");
    }
    else if(bytes>=(1024*1024)&&bytes<(1024*1024*1024))
    {
        freeString = QString::number(bytes/(1024*1024),'f', 2)+" "+tr("MB");
    }
    else
    {
        freeString = QString::number(bytes/(1024*1024*1024),'f', 2)+" "+tr("GB");
    }
    if(si.isRoot())return ""; //another AppArmor frustration...
    qDebug()<<"Free space on folder "<<si.displayName()<<": "<<freeString;
    return tr("Free space:")+" "+freeString;
}
