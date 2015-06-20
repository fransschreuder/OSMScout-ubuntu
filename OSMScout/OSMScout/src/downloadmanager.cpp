#include "downloadmanager.h"
//#include "downloadwidget.h"

#include <QFileInfo>
#include <QDateTime>
#include <QDebug>
#include <QDir>


DownloadManager::DownloadManager(QObject *parent) :
    QObject(parent)
    , _pHTTP(NULL)
{
}


void DownloadManager::download(QUrl url, QString downloadPath)
{
    QDir dir(downloadPath);
    dir.mkpath(downloadPath);
    _URL = url;

    _pHTTP = new DownloadManagerHTTP(this);

    connect(_pHTTP, SIGNAL(addLine(QString)), this, SLOT(localAddLine(QString)));
    connect(_pHTTP, SIGNAL(progress(int)), this, SLOT(localProgress(int)));
    connect(_pHTTP, SIGNAL(downloadComplete()), this, SLOT(localDownloadComplete()));

    _pHTTP->download(_URL, downloadPath);
}


void DownloadManager::pause()
{
    _pHTTP->pause();
}


void DownloadManager::resume()
{
    _pHTTP->resume();
}


void DownloadManager::localAddLine(QString qsLine)
{
    emit addLine(qsLine);
}


void DownloadManager::localProgress(int nPercentage)
{
    emit progress(nPercentage);
}


void DownloadManager::localDownloadComplete()
{
    emit downloadComplete();
}
#include <QCryptographicHash>
// Returns empty QString() on failure.
QString DownloadManager::md5sum(const QString &fileName)
{
    QFile f(fileName);
    if (f.open(QFile::ReadOnly)) {
        QCryptographicHash hash(QCryptographicHash::Md5);
        if (hash.addData(&f)) {
            QByteArray arr = hash.result();
            QString res;
            for(int i=0; i<arr.length(); i++)
            {
                res.append(QString("%1").arg((int)arr[i], 2, 16, QChar('0')));
            }
            return res;
        }
    }
    return QString();
}

bool DownloadManager::checkmd5sum(const QString path, const QString & fileName)
{
    if(fileName=="md5sums")return true;
    QString calcsum = md5sum(path+"/"+fileName);
    qDebug()<<"Calculated md5sum "<<calcsum<<" "<<fileName;
    QFile f(path+"/md5sums");
    if (f.open(QFile::ReadOnly)) {
        while (!f.atEnd()) {
            QString line = QString(f.readLine());
            if(line.contains(calcsum)&&line.contains(fileName))
            {
                qDebug()<<"checksum correct: "<<line;
                return true;
            }
        }
        return false;
    }
    else
    {
        return false;
    }
}

/////////////////////////////////

DownloadListItem::DownloadListItem( const QString& name,
             const QString& size,
             QObject* parent): QObject(parent)
{
    m_name = name;
    m_size = size;
}

DownloadListItem::~DownloadListItem()
{

}


QString DownloadListItem::getName() const
{
    return m_name;
}

QString DownloadListItem::getSize() const
{
    return m_size;
}


////////////////////////
DownloadListModel::DownloadListModel(QObject* parent): QAbstractListModel(parent)
{
    QUrl url("http://schreuderelectronics.com/osm/index.php");
    connect(
      &m_WebCtrl, SIGNAL (finished(QNetworkReply*)),
      this, SLOT (fileDownloaded(QNetworkReply*))
      );

    QNetworkRequest request(url);
    m_WebCtrl.get(request);


}

DownloadListModel::~DownloadListModel()
{
    for (QList<DownloadListItem*>::iterator item=downloadListItems.begin();
         item!=downloadListItems.end();
         ++item) {
        delete *item;
    }

    downloadListItems.clear();
}

#include <iostream>

void DownloadListModel::fileDownloaded(QNetworkReply* pReply) {
 m_DownloadedData = pReply->readAll();
 //emit a signal
 pReply->deleteLater();
 QString indexDoc(m_DownloadedData);

 QStringList links = indexDoc.split("<a href='");
 for(int i=1; i<links.size(); i++) //start at 1, to remove html header
 {
     QStringList splitLinks = links[i].split("'");
     if(splitLinks.size()<1)continue;
     QString name = splitLinks[0];
     QString size = splitLinks[1].split("</a> ")[1].split("<br/>")[0];
     DownloadListItem* item = new DownloadListItem(name, size);
     beginInsertRows(QModelIndex(), 0,0);
     downloadListItems.append(item);
     endInsertRows();
     std::cout<<"Map name: "<<name.toLocal8Bit().data()<<std::endl;
     std::cout<<"Map size: "<<size.toLocal8Bit().data()<<std::endl;
 }
 std::cout<<"*DownloadListModel size: "<<downloadListItems.size()<<std::endl;
 //emit
 emit downloaded();


}

QVariant DownloadListModel::data(const QModelIndex &index, int role) const
{
    if(index.row() < 0 || index.row() >= downloadListItems.size()) {
        return QVariant();
    }

    DownloadListItem* item = downloadListItems.at(index.row());
    switch (role) {
    case Qt::DisplayRole:
    case NameRole:
        return item->getName();
    case SizeRole:
        return item->getSize();
    default:
        break;
    }

    return QVariant();
}

int DownloadListModel::rowCount(const QModelIndex &parent) const
{
    std::cout<<"DownloadListModel size: "<<downloadListItems.size()<<std::endl;
    return downloadListItems.size();
}

Qt::ItemFlags DownloadListModel::flags(const QModelIndex &index) const
{
    if(!index.isValid()) {
        return Qt::ItemIsEnabled;
    }

    return QAbstractListModel::flags(index) | Qt::ItemIsEnabled | Qt::ItemIsSelectable;
}

QHash<int, QByteArray> DownloadListModel::roleNames() const
{
    QHash<int, QByteArray> roles=QAbstractListModel::roleNames();

    roles[SizeRole]="size";
    roles[NameRole]="name";

    return roles;
}

QString DownloadListModel::get(int row) const
{
    return downloadListItems.at(row)->getName();
}
