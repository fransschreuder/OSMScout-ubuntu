#ifndef UNITYSCREEN_H
#define UNITYSCREEN_H

#include <QObject>

class QDBusInterface;

class UnityScreen : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool keepDisplayOn READ keepDisplayOn WRITE setKeepDisplayOn NOTIFY keepDisplayOnChanged)

public:
    explicit UnityScreen(QObject *parent = 0);
    ~UnityScreen();

Q_SIGNALS:
    void keepDisplayOnChanged();

protected:
    bool keepDisplayOn() const;
    void setKeepDisplayOn(bool keepDisplayOn);

    int m_keepDisplayOnRequest;
    QDBusInterface *m_iface;
};

#endif // UNITYSCREEN_H
