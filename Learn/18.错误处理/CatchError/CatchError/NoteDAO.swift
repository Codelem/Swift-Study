

import Foundation

class NoteDAO {
    //保存数据列表
    private var listData = [Note]()
    
    //插入Note方法
    func create(_ model: Note) {
        listData.append(model)
    }
    
    //删除Note方法
    func remove(_ model: Note) throws {
        
        guard let date = model.date else {
            //抛出"主键为空"错误
            throw DAOError.primaryKeyNull
        }
        //比较日期主键是否相等
        for (index, note) in listData.enumerated() where note.date == date {
            listData.remove(at: index)
        }

    }
    
    //修改Note方法
    func modify(_ model: Note) throws {
        
        guard let date = model.date else {
            //抛出"主键为空"错误
            throw DAOError.primaryKeyNull
        }
        //比较日期主键是否相等
        for note in listData where note.date == date {
            note.content = model.content
        }
    }
    
    //查询所有数据方法
    func findAll() throws -> [Note] {
        
        guard listData.count > 0 else {
            //抛出"没有数据"错误。
            throw DAOError.noData
        }
        
        defer {
            print("关闭数据库")
        }
        defer {
            print("释放语句对象")
        }
        return listData
    }
    
    //修改Note方法
    func findById(_ model: Note) throws -> Note? {
        
        guard let date = model.date else {
            //抛出"主键为空"错误
            throw DAOError.primaryKeyNull
        }
        //比较日期主键是否相等
        for note in listData where note.date == date {
            return note
        }
        return nil
    }
    
}
