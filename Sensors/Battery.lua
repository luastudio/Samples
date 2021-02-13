-- Battery.lua
-- Battery info on iOS and android devices

Battery = Lib.Media.Sensors.Battery
print("Battery level(%): "..Battery.getLevel())
status = Battery.getStatus()
if(status == Battery.BATTERY_STATUS_UNKNOWN)then
  print("Unknown status")
elseif(status == Battery.BATTERY_STATUS_DISCHARGING)then
  print("Discharging status") -- not supported on iOS
elseif(status == Battery.BATTERY_STATUS_CHARGING)then
  print("Charging status")
elseif(status == Battery.BATTERY_STATUS_NOT_CHARGING)then
  print("Not charging status")
elseif(status == Battery.BATTERY_STATUS_FULL)then
  print("Full status")
end