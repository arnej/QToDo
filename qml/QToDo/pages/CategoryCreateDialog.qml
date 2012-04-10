import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog
{
    id: root

    titleText: "Create category"

    property alias categoryTitle: titleField.text

    content: Column {
        spacing: 8
        anchors.left: parent.left
        anchors.right: parent.right

        Label
        {
            id: titleLabel

            text: "Title:"
            color: platformStyle.colorNormalLight
            font.pixelSize: platformStyle.fontSizeMedium
        }

        TextField
        {
            id: titleField

            placeholderText: "Enter category name..."
            anchors.right: parent.right
            anchors.left: parent.left
        }
    }

    buttons: ButtonRow {
        anchors
        {
            left: parent.left
            right: parent.right
            margins: 16
        }

        Button
        {
            text: "Ok"
            onClicked: root.accept()
        }

        Button
        {
            text: "Cancel"
            onClicked: root.reject()
        }
    }
}
