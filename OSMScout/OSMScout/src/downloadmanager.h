#ifndef DOWNLOADMANAGER_H
#define DOWNLOADMANAGER_H

#include <QtGlobal>
#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QFile>
#include <QTimer>
#include <QtGui>

#include "downloadmanagerHTTP.h"




class DownloadManager : public QObject
{
    Q_OBJECT

public:
    explicit DownloadManager(QObject *parent = 0);

signals:
    void addLine(QString qsLine);
    void progress(int nPercentage);
    void downloadComplete();

public slots:
    void download(QUrl url, QString downloadPath);
    void pause();
    void resume();
    QString md5sum(const QString &fileName);
    bool checkmd5sum(const QString path, const QString & fileName);

private slots:
    void localAddLine(QString qsLine);
    void localProgress(int nPercentage);
    void localDownloadComplete();

private:
    QUrl _URL;
    DownloadManagerHTTP *_pHTTP;
};

///////////////

class DownloadListItem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ getName)
    Q_PROPERTY(QString path READ getSize)

private:
    QString                        m_name;
    QString                        m_size;


public:
    DownloadListItem( const QString& name,
                      const QString& size,
                      QObject* parent = 0);

    virtual ~DownloadListItem();


    QString getName() const;
    QString getSize() const;
};


class DownloadListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount)

public slots:
private slots:
  void fileDownloaded(QNetworkReply* pReply);
signals:
    void downloaded();
private:
    QList<DownloadListItem*> downloadListItems;

    QNetworkAccessManager m_WebCtrl;
    QByteArray m_DownloadedData;

public:
    enum Roles {
            NameRole = Qt::UserRole + 1,
            SizeRole
        };

public:
    DownloadListModel(QObject* parent = 0);
    ~DownloadListModel();
    QVariant data(const QModelIndex &index, int role) const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const;

    Qt::ItemFlags flags(const QModelIndex &index) const;

    QHash<int, QByteArray> roleNames() const;

    Q_INVOKABLE QString get(int row) const;
};


#endif // DOWNLOADMANAGER_H
