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
      Category.base_category.normal.sorted.latest
    else
      @shop.categories.normal.sorted.latest
    end
  end

  def user_sub_categories
    if current_user.admin?
      SubCategory.base_category.normal.sorted.latest
    else
      @shop.sub_categories.normal.sorted.latest
    end
  end

  def user_detail_categories
    if current_user.admin?
      DetailCategory.base_category.normal.sorted.latest
    else
      @shop.detail_categories.normal.sorted.latest
    end
  end

  def get_select_product_html(product)
    return "<input type='text' name='product_price' id='product_price' class='form-control' value='#{product.price}'>"
  end

  def time_show(time)
    time.strftime("%Y-%m-%d %H:%M:%S") if time.present?
  end

  def valid_shop_path?
    %w(shop_models shops products units top_searches users registrations).include?(controller_name)
  end

  def valid_statistics_show_path?
    controller_name == 'order_statistics' && action_name == 'show'
  end

  def update_keys(obj, key_params, logo_key_params=nil)
    key_params.to_a.each do |k|
      obj.update(key: k)
    end
    logo_key_params.to_a.each do |k|
      obj.update(logo_key: k)
    end
  end
end
