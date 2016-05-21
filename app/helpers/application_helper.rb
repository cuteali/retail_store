module ApplicationHelper
  def header(text)
    content_for(:header) { text.to_s }
  end

  def invalid_path?
    return true if controller_name == 'home'
    return true if controller_name == 'sessions' && action_name == 'new'
    return true if controller_name == 'passwords' && action_name == 'new'
    return true if controller_name == 'passwords' && action_name == 'edit'
  end

  def crumb_name(obj)
    obj.new_record? ? '新增' : '修改'
  end

  def get_select_category_html(options, id, name, first_option)
    html = ""
    html << "<select id='#{id}' name='#{name}' class='form-control'>" if options
    html << "<option value=''>#{first_option}</option>" if options
    options.each do |option|
      html << "<option value='#{option.id}'>#{option.name}</option>"
    end
    html << "</select>" if options
    return html
  end

  def user_categories
    if current_user.admin?
      Category.base_category.normal.sorted
    else
      @shop.categories.normal.sorted
    end
  end

  def user_sub_categories
    if current_user.admin?
      SubCategory.base_category.normal.sorted
    else
      @shop.sub_categories.normal.sorted
    end
  end

  def user_detail_categories
    if current_user.admin?
      DetailCategory.base_category.normal.sorted
    else
      @shop.detail_categories.normal.sorted
    end
  end
end
