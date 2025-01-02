module ApplicationHelper
  def flash_class(type)
    case type.to_sym
    when :notice
      "bg-green-500 text-white p-4 rounded-md mb-4"
    when :alert
      "bg-red-500 text-white p-4 rounded-md mb-4"
    when :error
      "bg-red-700 text-white p-4 rounded-md mb-4"
    else
      "bg-gray-500 text-white p-4 rounded-md mb-4"
    end
  end
end
