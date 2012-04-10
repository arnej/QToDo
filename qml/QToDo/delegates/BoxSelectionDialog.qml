import QtQuick 1.1
import com.nokia.symbian 1.1

SelectionDialog
{
    id: root

    titleText: "Select a box"
    delegate: itemDelegate

    Component
    {
        id: itemDelegate

        MenuItem
        {
            text: model.title
            onClicked:
            {
                selectedIndex = index
                root.accept()
            }
        }
    }
}
