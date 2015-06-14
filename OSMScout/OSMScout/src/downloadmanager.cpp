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
