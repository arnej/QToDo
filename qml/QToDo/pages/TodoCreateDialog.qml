import QtQuick 1.1
import com.nokia.symbian 1.1
import "../delegates"
import "../js/core.js" as Core

CommonDialog
{
    id: root

    titleText: "Create Todo"

    property int boxId: 0
    property alias todoTitle: titleField.text

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

            placeholderText: "Enter todo title..."
            anchors.right: parent.right
            anchors.left: parent.left
        }

        Label
        {
            id: boxLabel

            text: "Category:"
            color: platformStyle.colorNormalLight
            font.pixelSize: platformStyle.fontSizeMedium
        }

        ListModel
        {
            id: boxModel
        }

        SelectionListItem
        {
            id: itemSelection

            anchors.left: parent.left
            anchors.right: parent.right

            BoxSelectionDialog
            {
                id: selectionDialog

                titleText: "Select Box"

                onAccepted:
                {
                    itemSelection.title = model.get(selectedIndex).title;
                    boxId = model.get(selectedIndex).box;
                }

                onSelectedIndexChanged:
                {
                    itemSelection.title = model.get(selectedIndex).title;
                    boxId = model.get(selectedIndex).box;
                }
            }

            onClicked: selectionDialog.open()
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

    onStatusChanged:
    {
        if(status === DialogStatus.Opening)
        {
            todoTitle = ""
            loadModel()
            itemSelection.title = Core.readCategoryTitle(boxId)
        }
    }

    function loadModel()
    {
        selectionDialog.model = 0
        Core.readCategories(boxModel)
        selectionDialog.model = boxModel
    }
}
