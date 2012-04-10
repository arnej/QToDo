import QtQuick 1.1
import com.nokia.symbian 1.1

ListItem
{
    id: listItem

    property alias title: boxTitle.text
    property alias count: boxCount.text

    ListItemText
    {
        id: boxTitle
        mode: listItem.mode
        anchors.verticalCenter: parent.verticalCenter
    }

    ListItemText
    {
        id: boxCount
        mode: listItem.mode
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
    }
}
