class TargetSerializer < ActiveModel::Serializer
  attributes :id, :start_date, :end_date, :weight, :fat_percentage, :body_age, :bmi, :rm, :visc_fat, :sc_fat, :muscle_percentage, :fat_kg, :muscle_kg, :other_kg, :fat_loss, :muscle_gain, :user_id
end
