import QtQuick 1.1
import com.nokia.symbian 1.1
import "../delegates"
import "../js/core.js" as Core

Page
{
    id: homePage

    ListView
    {
        id: boxView

        anchors.fill: parent
        model: boxModel
        clip: true

        delegate: BoxItemDelegate {
            id: itemDelegate

            title: model.title
            count: model.count
            onClicked: pageStack.push(window.boxPage, { boxId: model.box, title: model.title, state: "default" })
            onPressAndHold:
            {
                categoryContextMenu.boxId = model.box
                categoryContextMenu.boxTitle = model.title
                categoryContextMenu.open()
            }
        }
    }

    Menu
    {
        id: toolBarMenu

        anchors.bottom: homePage.bottom

        content: MenuLayout {
            MenuItem
            {
                id: archiveMenuItem
                text: getArchiveText()
                onClicked: pageStack.push(window.boxPage, { title: "Archive", state: "archive" })
            }

            MenuItem
            {
                text: "Create category"
                onClicked:
                {
                    categoryCreateDialog.state = "default"
                    categoryCreateDialog.categoryTitle = ""
                    categoryCreateDialog.open()
                }
            }
        }
    }

    CategoryCreateDialog
    {
        id: categoryCreateDialog

        onAccepted:
        {
            if(categoryTitle != "")
            {
                if(categoryCreateDialog.state == "default") Core.createCategory(categoryTitle)
                else if(categoryCreateDialog.state == "rename") Core.renameCategory(categoryContextMenu.boxId, categoryCreateDialog.categoryTitle)
                updateUi()
            }
        }
    }

    tools: ToolBarLayout {
        id: homeSpecificTools

        ToolButton
        {
            iconSource: "toolbar-back"
            onClicked: Qt.quit();
        }

        ToolButton
        {
            iconSource: "toolbar-menu"
            onClicked: toolBarMenu.open()
        }

        ToolButton
        {
            iconSource: "toolbar-add"
            onClicked: todoCreateDialog.open()
        }
    }

    TodoCreateDialog
    {
        id: todoCreateDialog

        onAccepted:
        {
            if(todoTitle != "")
            {
                var item = Core.defaultItem()
                item.box = boxId
                item.title = todoTitle
                Core.createTodo(item)
                updateUi()
            }
        }
    }

    ListModel
    {
        id: boxModel
    }

    ContextMenu
    {
        id: categoryContextMenu

        property int boxId: 0
        property string boxTitle: ""

        MenuLayout
        {
            MenuItem
            {
                text: "Rename"
                onClicked:
                {
                    categoryCreateDialog.categoryTitle = categoryContextMenu.boxTitle
                    categoryCreateDialog.state = "rename"
                    categoryCreateDialog.open()
                }
            }

            MenuItem
            {
                text: "Delete"
                visible: categoryContextMenu.boxId != 0
                onClicked:
                {
                    categoryDeleteYesNoDialog.boxId = categoryContextMenu.boxId
                    categoryDeleteYesNoDialog.open()
                }
            }
        }
    }

    YesNoDialog
    {
        id: categoryDeleteYesNoDialog

        property int boxId: 0

        titleText: "Delete category?"
        subText: "All items in it will be moved to first category."

        onAccepted: { Core.deleteCategory(boxId); updateUi() }
    }

    onStatusChanged:
    {
        if(status === PageStatus.Activating)
        {
            header.text = "Categories"
            todoCreateDialog.loadModel()
            updateUi()
        }
    }

    function updateUi()
    {
        boxView.model = 0
        Core.readCategories(boxModel)
        boxView.model = boxModel
        archiveMenuItem.text = getArchiveText()
    }

    function getArchiveText()
    {
        return "Archive (" + Core.readArchiveCount() + ")"
    }
}

