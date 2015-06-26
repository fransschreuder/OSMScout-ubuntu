#ifndef MAPLISTMODEL_H
#define MAPLISTMODEL_H

#include <QtGui>
#include "DBThread.h"

class MapListItem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ getName)
    Q_PROPERTY(QString path READ getPath)

private:
    QString                        m_name;
    QString                        m_path;


public:
    MapListItem( const QString& name,
                 const QString& path,
                 QObject* parent = 0);

    virtual ~MapListItem();


    QString getName() const;
    QString getPath() const;
};


class MapListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount)

public slots:

private:
    QList<MapListItem*> mapListItems;

public:
    enum Roles {
            NameRole = Qt::UserRole + 1,
            PathRole
        };

public:
    MapListModel(QObject* parent = 0);
    ~MapListModel();
    Q_INVOKABLE QString getPreferredDownloadDir() const{
        return DBThread::GetInstance()->getPreferredDownloadDir();
    }
    Q_INVOKABLE QString getFreeSpace();

    QVariant data(const QModelIndex &index, int role) const;

    int rowCount(const QModelIndex &parent = QModelIndex()) const;

    Qt::ItemFlags flags(const QModelIndex &index) const;

    QHash<int, QByteArray> roleNames() const;

    Q_INVOKABLE QString get(int row) const;
    Q_INVOKABLE bool deleteItem(int row);
    Q_INVOKABLE bool refreshItems();
};
#endif
