import QtQuick 1.1
import com.nokia.symbian 1.1
import "../delegates"
import "../js/core.js" as Core

Page
{
    id: boxPage

    property int boxId: 0
    property string title

    ListView
    {
        id: itemView
        anchors.fill: parent
        model: itemModel
        clip: true

        delegate: TodoItemDelegate {
            id: todoItemDelegate
            title: model.title
            checked: model.done
            onClicked: pageStack.push(window.todoPage, { todoId: model.id, state: boxPage.state == "archive" ? "archive" : "details" } )

            onCheckBoxClicked:
            {
                if(checked !== model.done)
                {
                    itemModel.setProperty(index, 'done', checked)
                    if(boxPage.state == "default") Core.updateTodo(model)
                    else if(boxPage.state == "archive") Core.updateArchiveItem(model)
                }
            }

            onPressAndHold: { itemContextMenu.itemId = model.id; itemContextMenu.open() }
        }
    }

    tools: ToolBarLayout {
        id: boxSpecificTools

        ToolButton
        {
            iconSource: "toolbar-back"
            onClicked: pageStack.pop();
        }

        ToolButton
        {
            id: reloadTodosButton
            anchors.centerIn: parent
            iconSource: "toolbar-refresh"
            onClicked:
            {
                if(pageStack.depth === 2)
                    if(boxPage.state == "default") Core.moveToArchive()
                    else if(boxPage.state == "archive") Core.moveBackFromArchive()

                updateUi()
            }
        }

        ToolButton
        {
            id: addButton
            anchors.right: parent.right
            iconSource: "toolbar-add"
            onClicked: { todoCreateDialog.boxId = boxId; todoCreateDialog.open() }
        }

        ToolButton
        {
            id: clearArchiveButton
            iconSource: "toolbar-delete"
            onClicked: clearArchiveDialog.open()
        }
    }

    YesNoDialog
    {
        id: clearArchiveDialog

        titleText: "Clear complete archive?"

        onAccepted:
        {
            Core.clearArchive()
            pageStack.pop()
        }
    }

    YesNoDialog
    {
        id: deleteItemDialog

        titleText: "Delete item?"

        onAccepted:
        {
            if(boxPage.state == "default") Core.deleteTodo(itemContextMenu.itemId)
            else if(boxPage.state == "archive") Core.deleteArchiveItem(itemContextMenu.itemId)
            updateUi()
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
        id: changeCategoryListModel
    }

    SelectionDialog
    {
        id: changeCategoryDialog

        property int itemId: 0
        property int boxId: 0

        model: changeCategoryListModel
        delegate: MenuItem {
            text: model.title
            visible: model.box != boxId
            height: visible ? 80 : 0

            onClicked:
            {
                Core.changeTodoCategory(itemId, model.box)
                changeCategoryDialog.accept()
                updateUi()
            }
        }
    }

    ContextMenu
    {
        id: itemContextMenu

        property int itemId

        MenuLayout
        {
            MenuItem
            {
                id: changeCatagoryMenuItem

                text: "Change category"

                onClicked:
                {
                    changeCategoryDialog.model = 0
                    Core.readCategories(changeCategoryListModel)
                    changeCategoryDialog.model = changeCategoryListModel
                    changeCategoryDialog.itemId = itemContextMenu.itemId
                    changeCategoryDialog.boxId = boxId
                    changeCategoryDialog.open()
                }
            }

            MenuItem
            {
                id: deleteMenuItem

                text: "Delete"

                onClicked:
                {
                    deleteItemDialog.open()
                }
            }
        }
    }

    ListModel
    {
        id: itemModel
    }

    onStatusChanged:
    {
        if(status === PageStatus.Activating)
        {
            updateUi()
            header.text = boxPage.title
        }
        else if(status === PageStatus.Deactivating)
        {
            if(pageStack.depth === 1)
                if(boxPage.state == "default") Core.moveToArchive()
                else if(boxPage.state == "archive") Core.moveBackFromArchive()
        }
    }

    states: [
        State {
            name: "default"
            PropertyChanges { target: addButton; visible: true }
            PropertyChanges { target: clearArchiveButton; visible: false }
            PropertyChanges { target: changeCatagoryMenuItem; visible: true }
        },
        State {
            name: "archive"
            PropertyChanges { target: addButton; visible: false }
            PropertyChanges { target: clearArchiveButton; visible: true }
            PropertyChanges { target: changeCatagoryMenuItem; visible: false }
        }
    ]

    function updateUi()
    {
        itemView.model = 0
        if(state == "default") Core.readTodoBox(itemModel, boxId)
        else if(state == "archive") Core.readArchive(itemModel)
        itemView.model = itemModel
    }
}
