class ScheduleSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :workout_type, :fitness_test_id, 
  :scheduled_date, :completion_percentage, :rating, :comments, :completed

    belongs_to :exercise
end
