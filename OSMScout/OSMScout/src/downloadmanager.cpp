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


