
def convert_short(record_name)
  record_name.length > 20 ? record_name[0,20] + '...' : record_name
end
