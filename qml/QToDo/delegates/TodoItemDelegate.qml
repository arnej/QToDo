import QtQuick 1.1
import com.nokia.symbian 1.1

ListItem
{
    id: listItem

    property alias title: todoTitle.text
    property alias checked: checkBox.checked
    property alias checkBoxVisible: checkBox.visible
    signal checkBoxClicked()

    Row
    {
        id: row

        anchors.fill: listItem.paddingItem
        spacing: 8

        CheckBox
        {
            id: checkBox
            anchors.verticalCenter: parent.verticalCenter
            onClicked: listItem.checkBoxClicked()
        }

        ListItemText
        {
            id: todoTitle
            mode: listItem.mode
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - checkBox.width
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            maximumLineCount: 3
        }
    }
}
