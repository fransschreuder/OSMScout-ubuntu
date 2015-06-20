#include "UnityScreen.h"

#include <QDBusInterface>
#include <QDBusPendingCall>

UnityScreen::UnityScreen(QObject *parent) :
    QObject(parent),
    m_keepDisplayOnRequest(-1)
{
    m_iface = new QDBusInterface("com.canonical.Unity.Screen", "/com/canonical/Unity/Screen", "com.canonical.Unity.Screen", QDBusConnection::systemBus());
}

UnityScreen::~UnityScreen() {

}

bool UnityScreen::keepDisplayOn() const
{
    return m_keepDisplayOnRequest != -1;
}

void UnityScreen::setKeepDisplayOn(bool keepDisplayOn)
{
    if (m_keepDisplayOnRequest == -1 && keepDisplayOn) {
        // set request
        QDBusMessage reply = m_iface->call("keepDisplayOn");
        if (reply.arguments().count() > 0) {
            m_keepDisplayOnRequest = reply.arguments().first().toInt();
            emit keepDisplayOnChanged();
        }
    } else if (m_keepDisplayOnRequest != -1 && !keepDisplayOn) {
        // clear request
        m_iface->asyncCall("removeDisplayOnRequest", m_keepDisplayOnRequest);
        m_keepDisplayOnRequest = -1;
        emit keepDisplayOnChanged();
    }
}
