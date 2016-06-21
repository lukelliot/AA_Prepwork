class Student
  attr_accessor :first_name, :last_name
  attr_reader :courses

  def initialize(first_name, last_name)
    @first_name = first_name
    @last_name = last_name
    @courses = []
  end

  def name
    "#{@first_name} #{@last_name}"
  end

  def enroll(course)
    unless @courses.include?(course) || has_conflict?(course)
      @courses << course
      course.students.push(self)
    else
      raise "This course conflicts with your current schedule!"
    end
  end

  def has_conflict?(course2)
    @courses.any? do |course1|
      course1.conflicts_with?(course2)
    end
  end

  def course_load
    course_hash = Hash.new(0)

    @courses.each do |course|
      course_hash[course.department] += course.credits
    end

    course_hash
  end
end
