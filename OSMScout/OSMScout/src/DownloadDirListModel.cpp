#include "DownloadDirListModel.h"
#include "DBThread.h"

DownloadDirListItem::DownloadDirListItem(  const QString& path,
             QObject* parent): QObject(parent)
{
    m_path = path;
}

DownloadDirListItem::~DownloadDirListItem()
{

}

QString DownloadDirListItem::getPath() const
{
    return m_path;
}

////////////////////////
DownloadDirListModel::DownloadDirListModel(QObject* parent): QAbstractListModel(parent)
{
    DBThread* dbThread = DBThread::GetInstance();
    QStringList dirs = dbThread->getValidDownloadDirs();
    for(int i=0; i<dirs.size(); i++)
    {
        downloadDirListItems.append(new DownloadDirListItem(dirs[i]));
    }

}



DownloadDirListModel::~DownloadDirListModel()
{
    for (QList<DownloadDirListItem*>::iterator item=downloadDirListItems.begin();
         item!=downloadDirListItems.end();
         ++item) {
        delete *item;
    }

    downloadDirListItems.clear();
}

QVariant DownloadDirListModel::data(const QModelIndex &index, int role) const
{
    if(index.row() < 0 || index.row() >= downloadDirListItems.size()) {
        return QVariant();
    }

    DownloadDirListItem* item = downloadDirListItems.at(index.row());
    switch (role) {
    case Qt::DisplayRole:
    case PathRole:
        return item->getPath();
    default:
        break;
    }

    return QVariant();
}

int DownloadDirListModel::rowCount(const QModelIndex &parent) const
{
    return downloadDirListItems.size();
}

Qt::ItemFlags DownloadDirListModel::flags(const QModelIndex &index) const
{
    if(!index.isValid()) {
        return Qt::ItemIsEnabled;
    }

    return QAbstractListModel::flags(index) | Qt::ItemIsEnabled | Qt::ItemIsSelectable;
}

QHash<int, QByteArray> DownloadDirListModel::roleNames() const
{
    QHash<int, QByteArray> roles=QAbstractListModel::roleNames();
    roles[PathRole]="path";
    return roles;
}
