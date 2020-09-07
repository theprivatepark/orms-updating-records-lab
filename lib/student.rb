require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade
  attr_reader :id

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS students (
          id INTEGER PRIMARY KEY,
          name TEXT,
          grade TEXT
          )"
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def save
    if self.id != nil#student exists in DB, 
      self.update #update student
    else #make new row of student
        sql = "INSERT INTO students (name, grade)
              VALUES (?, ?)"
        DB[:conn].execute(sql,self.name, self.grade)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end
   
  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student 
  end

  def self.new_from_db(row)
    new_student = Student.new(row[0],row[1], row[2])
  end

  def self.find_by_name(name)
    sql = "SELECT *
          FROM students
          where name = ?"

    query_result = DB[:conn].execute(sql, name)
    Student.new_from_db(query_result[0])
  end

  def update
    sql = "UPDATE students
          SET name = ?,
          grade = ?
          WHERE id = ?
          "
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end
