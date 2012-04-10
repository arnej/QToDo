import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog
{
    id: yesNoDialog

    property alias subText: subTextLabel.text

    titleText: "Yes or No"

    content: Column {
        Label
        {
            id: subTextLabel

            visible: text != ""
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
            text: "Yes"
            onClicked: yesNoDialog.accept()
        }

        Button
        {
            text: "No"
            onClicked: yesNoDialog.reject()
        }
    }
}
