import QtQuick 1.1
import com.nokia.symbian 1.1
import "pages"
import "delegates"
import "js/core.js" as Core

PageStackWindow
{
    property variant boxPage: BoxPage {}
    property variant todoPage: TodoPage { state: "details" }

    id: window
    initialPage: HomePage {}
    showStatusBar: true
    showToolBar: true

    TitleHeader
    {
        id: header

        text: "Categories"
    }

    Component.onCompleted:
    {
        Core.openDB()
    }
}
