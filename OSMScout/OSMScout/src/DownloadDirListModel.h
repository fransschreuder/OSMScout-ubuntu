#ifndef DOWNLOADDIRLISTMODEL_H
#define DOWNLOADDIRLISTMODEL_H
#include <QtGui>
////////////////////////////
class DownloadDirListItem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString path READ getPath)

private:
    QString                        m_path;


public:
    DownloadDirListItem( const QString& path,
                        QObject* parent = 0);

    virtual ~DownloadDirListItem();

    QString getPath() const;
};


class DownloadDirListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount)

public slots:

private:
    QList<DownloadDirListItem*> downloadDirListItems;

public:
    enum Roles {
            PathRole = Qt::UserRole + 1
        };

public:
    DownloadDirListModel(QObject* parent = 0);
    ~DownloadDirListModel();
    QVariant data(const QModelIndex &index, int role) const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    Qt::ItemFlags flags(const QModelIndex &index) const;
    QHash<int, QByteArray> roleNames() const;
};

#endif
