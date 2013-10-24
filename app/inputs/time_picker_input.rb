class Cocoonase::Inputs::TimePickerInput < Cocoonase::Inputs::DateTimePickerInput
  def icon_class
    'icon-time'
  end

  def picker_class
    'time-picker bootstrap-timepicker'
  end
end
