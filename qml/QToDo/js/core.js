var _db

function openDB() {
    _db = openDatabaseSync("TodoDB","1.0","Todo Database",1000000)
    createTables()
}

function createTables() {
    _db.transaction( function(tx) {
                        tx.executeSql("Create Table If Not Exists todo ( id Integer Primary Key Autoincrement, \
                                      box Integer, \
                                      done Text, \
                                      title Text, \
                                      note Text, \
                                      modified Text \
                                      )")
                    })

    _db.transaction( function(tx) {
                        tx.executeSql("Create Table If Not Exists archive ( id Integer Primary Key Autoincrement, \
                                      box Integer, \
                                      done Text, \
                                      title Text, \
                                      note Text, \
                                      modified Text \
                                      )")
                    })

    _db.transaction( function(tx) {
                        tx.executeSql("Create Table If Not Exists settings ( id Text Primary Key, value Text)")
                    })

    _db.transaction( function(tx) {
                        tx.executeSql("Create Table If Not Exists categories ( id Integer Primary Key Autoincrement, \
                                      box int, \
                                      title Text)")

                        if(readSettings('categories_created') !== 'true')
                            tx.executeSql("Insert Into categories ( 'box', 'title' ) Values ( 0, 'Common' )")
                        tx.executeSql("Insert Or Replace Into settings Values ( 'categories_created', 'true' )")
                    })
}

function readSettings(key)
{
    var data = ""
    _db.readTransaction( function(tx) {
                            var rs = tx.executeSql("Select value From settings Where id = ?", [key])
                            if(rs.rows.length === 1) data = rs.rows.item(0).value
                        })
    return data
}

function updateTodo(todoItem)
{
    _db.transaction( function(tx) {
                        tx.executeSql("Update todo Set box = ? , done = ?, title = ?, note = ?, modified = ? Where id = ?",
                                      [ todoItem.box, todoItem.done, todoItem.title,
                                       todoItem.note, todoItem.modified, todoItem.id ]
                                      )
                    })
}

function renameCategory(boxId, categoryTitle)
{
    _db.transaction( function(tx) {
                        tx.executeSql("Update categories Set title = ? Where box = ?", [ categoryTitle, boxId ])
                    })
}

function deleteCategory(boxId)
{
    _db.transaction( function(tx) {
                        tx.executeSql("Update todo Set box = 0 Where box = ?", [ boxId ] )
                        tx.executeSql("Update archive Set box = 0 Where box = ?", [ boxId ] )
                        tx.executeSql("Delete From categories Where box = ?", [ boxId ] )
                    })
}

function changeTodoCategory(todoId, boxId)
{
    _db.transaction( function(tx) {
                        tx.executeSql("Update todo Set box = ? Where id = ?", [ boxId, todoId ])
                    })
}

function updateArchiveItem(archiveItem)
{
    _db.transaction( function(tx) {
                        tx.executeSql("Update archive Set box = ? , done = ?, title = ?, note = ?, modified = ? Where id = ?",
                                      [ archiveItem.box, archiveItem.done, archiveItem.title,
                                       archiveItem.note, archiveItem.modified, archiveItem.id ]
                                      )
                    })
}

function moveToArchive()
{
    _db.transaction( function(tx) {
                        var rs = tx.executeSql("Select * From todo Where done = 'true'")
                        for(var i = 0; i < rs.rows.length; i++)
                        {
                            tx.executeSql("Insert Into archive (box, done, title, note, modified) Values(?,?,?,?,?)",
                                          [ rs.rows.item(i).box, rs.rows.item(i).done, rs.rows.item(i).title,
                                           rs.rows.item(i).note, rs.rows.item(i).modified ])
                            tx.executeSql("Delete From todo Where id = ?", [ rs.rows.item(i).id ])
                        }
                    })
}

function moveBackFromArchive()
{
    _db.transaction( function(tx) {
                        var rs = tx.executeSql("Select * From archive Where done = 'false'")
                        for(var i = 0; i < rs.rows.length; i++)
                        {
                            tx.executeSql("Insert Into todo (box, done, title, note, modified) Values(?,?,?,?,?)",
                                          [ rs.rows.item(i).box, rs.rows.item(i).done, rs.rows.item(i).title,
                                           rs.rows.item(i).note, rs.rows.item(i).modified ])
                            tx.executeSql("Delete From archive Where id = ?", [ rs.rows.item(i).id ])
                        }
                    })
}

function clearArchive()
{
    _db.transaction( function(tx) {
                        tx.executeSql("Delete From archive")
                    })
}

function readArchiveCount()
{
    openDB()
    var data = ""
    _db.readTransaction( function(tx) {
                            // execute the sql statement to read from database
                            var rs = tx.executeSql("Select Count(*) As rowCount From archive")
                            // check that the id correspond to one unique row
                            if(rs.rows.length === 1) {
                                // store result into data variable
                                data = rs.rows.item(0).rowCount
                            }
                        })
    return data
}

function readTodoBox(model, boxId)
{
    openDB()
    model.clear()
    _db.readTransaction( function(tx) {
                            var rs = tx.executeSql("Select * From todo Where box = ? Order By title Asc", [ boxId ] )
                            for (var i=0; i< rs.rows.length; i++) {
                                model.append(rs.rows.item(i))
                            }
                        })
}

function readCategories(model)
{
    openDB()
    model.clear()
    _db.readTransaction( function(tx) {
                            var rs = tx.executeSql("Select id, box, title, ( Select Count(*) From todo Where todo.box = categories.box ) As count From categories")
                            for (var i=0; i< rs.rows.length; i++) {
                                model.append(rs.rows.item(i))
                            }
                        })
}

function readArchive(model)
{
    openDB()
    model.clear()
    _db.readTransaction( function(tx) {
                            var rs = tx.executeSql("Select * From archive Order By title Asc")
                            for (var i=0; i< rs.rows.length; i++) {
                                model.append(rs.rows.item(i))
                            }
                        })
}

function readTodoItem(todoId)
{
    openDB()
    var data = {}
    _db.readTransaction( function(tx) {
                            // execute the sql statement to read from database
                            var rs = tx.executeSql("Select * From todo Where id=?", [todoId])
                            // check that the id correspond to one unique row
                            if(rs.rows.length === 1) {
                                // store result into data variable
                                data = rs.rows.item(0)
                            }
                        })
    return data
}

function readArchiveItem(archiveId)
{
    openDB()
    var data = {}
    _db.readTransaction( function(tx) {
                            // execute the sql statement to read from database
                            var rs = tx.executeSql("Select * From archive Where id=?", [archiveId])
                            // check that the id correspond to one unique row
                            if(rs.rows.length === 1) {
                                // store result into data variable
                                data = rs.rows.item(0)
                            }
                        })
    return data
}

function readCategoryTitle(categoryId)
{
    var data = ""
    _db.readTransaction( function(tx) {
                            var rs = tx.executeSql("Select title From categories Where box=?", [categoryId])
                            if(rs.rows.length === 1) data = rs.rows.item(0).title
                        })
    return data
}

function defaultItem()
{
    openDB()
    return {box: 0, done: false, title: "", note: "", modified: new Date()}
}

function createTodo(todoItem)
{
    openDB()
    _db.transaction( function(tx) {
                        // execute the sql query to insert new item
                        tx.executeSql("Insert Into todo (box, done, title, note, modified) Values(?,?,?,?,?)",
                                      [ todoItem.box, todoItem.done, todoItem.title,
                                       todoItem.note, todoItem.modified ])
                    })
}

function createCategory(categoryTitle)
{
    _db.transaction( function(tx) {
                        // execute the sql query to insert new item
                        tx.executeSql("Insert Into categories ( 'box', 'title' ) Values ( ((Select Max(box) From categories)+1), ? )",
                                      [ categoryTitle ])
                    })
}

function deleteTodo(id)
{
    // create a Read/Write transition
    _db.transaction( function(tx) {
                        // execute sql query to delete item the given id.
                        tx.executeSql("Delete From todo Where id = ?", [ id ])
                    })
}

function deleteArchiveItem(id)
{
    // create a Read/Write transition
    _db.transaction( function(tx) {
                        // execute sql query to delete item the given id.
                        tx.executeSql("Delete From archive Where id = ?", [ id ])
                    })
}

function readBoxCount(boxId)
{
    openDB()
    var data = ""
    _db.readTransaction( function(tx) {
                            // execute the sql statement to read from database
                            var rs = tx.executeSql("Select Count(*) As rowCount From todo Where box=?", [boxId])
                            // check that the id correspond to one unique row
                            if(rs.rows.length === 1) {
                                // store result into data variable
                                data = rs.rows.item(0).rowCount
                            }
                        })
    return data
}
