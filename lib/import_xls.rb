module ImportXls
  def self.import(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      name_as, key, logo_key, is_app_index = get_name_as_and_key(row['大分类'])
      options = {}
      options[:shop_id] = 3
      options[:name_as] = name_as if name_as
      options[:key] = key if key
      options[:logo_key] = logo_key if logo_key
      options[:is_app_index] = is_app_index if is_app_index
      category = Category.where(name: row['大分类']).first_or_create(options)
      sub_category = category.sub_categories.where(name: row['小分类']).first_or_create(shop_id: 3)
      detail_category_key = get_detail_category_key(row['具体分类'], sub_category.name)
      detail_category = sub_category.detail_categories.where(name: row['具体分类']).first_or_create(shop_id: 3, category_id: category.id, key: detail_category_key)
      # @product1 = detail_category.shop_products.where(name: '商品1').first_or_create(shop_id: 3, category_id: category.id, sub_category_id: sub_category.id, unit_id: 1,
      #   price: 1, old_price: 2, stock_volume: 100, sales_volume: 0, key: '食品.jpg', desc: '商品描述1', info: '商品简介1', spec: '110g*18杯/箱', is_app_index: true)
      # @product2 = detail_category.shop_products.where(name: '商品2').first_or_create(shop_id: 3, category_id: category.id, sub_category_id: sub_category.id, unit_id: 1,
      #   price: 1, old_price: 2, stock_volume: 100, sales_volume: 0, key: '食品2.jpg', desc: '商品描述2', info: '商品简介2', spec: '200g*12/箱', is_app_index: true)
    end
    update_qiniu_key
    # advert1 = @product1.adverts.where(key: '广告1.jpg').first_or_create(shop_id: 3)
    # advert2 = @product2.adverts.where(key: '广告2.jpg').first_or_create(shop_id: 3)
    # advert3 = @product1.adverts.where(key: '广告3.jpg').first_or_create(shop_id: 3)
    # advert4 = @product2.adverts.where(key: '广告4.jpg').first_or_create(shop_id: 3)
  end

  def self.open_spreadsheet(file)
    case File.extname(file)
    when '.csv' then Roo::CSV.new(file, packed: false, file_warning: :ignore)
    when '.xls' then Roo::Excel.new(file, packed: false, file_warning: :ignore)
    when '.xlsx' then Roo::Excelx.new(file, packed: false, file_warning: :ignore)
    else raise "Unknown file type: #{file}"
    end
  end

  def self.update_qiniu_key
    Category.all.each do |c|
      name_as, key, logo_key, is_app_index = get_name_as_and_key(c.name)
      options = {}
      options[:shop_id] = nil
      options[:key] = key if key
      options[:logo_key] = logo_key if logo_key
      c.update_columns(options)
    end
    DetailCategory.all.each do |dc|
      detail_category_key = get_detail_category_key(dc.name, dc.sub_category.name)
      dc.update_columns(shop_id: nil, key: detail_category_key)
    end
  end

  def self.get_name_as_and_key(name)
    case name
    when '牛奶乳品' then ['牛奶', '牛奶@2x.png', '牛奶乳品.png', true]
    when '五谷杂粮' then ['杂粮', '杂粮@2x.png', '五谷杂粮.png', true]
    when '饼干蛋糕' then ['饼干', '饼干@2x.png', '饼干蛋糕.png', true]
    when '零食休闲' then ['零食', '零食@2x.png', '零食休闲.png', true]
    when '南北干货' then ['干货', '干货@2x.png', '南北干货.png', true]
    when '坚果炒货' then ['坚果', '坚果图@2x.png', '坚果炒货.png', true]
    when '美味糖果' then ['糖果', '糖果@2x.png', '美味糖果.png', true]
    when '花茶冲饮' then ['花茶', '花茶@2x.png', '花茶冲饮.png', true]
    when '酱菜调味' then ['调味', '调味.png', '酱菜调味.png', false]
    when '饮料酒水' then ['酒水', '酒水.png', '酒水饮料.png', false]
    when '方便速食' then ['速食', '速食.png', '方便速食.png', false]
    end
  end

  def self.get_detail_category_key(name, sub_name)
    case name
    when '红豆' then '红豆.jpg'
    when '绿豆' then '绿豆.jpg'
    when '黄豆' then '黄豆.jpg'
    when '芸豆' then '芸豆.jpg'
    when '黑豆' then '黑豆.jpg'
    when '其他豆类' then '其他豆类.jpg'
    when '糯米' then '糯米.jpg'
    when '黄米' then '黄米.jpg'
    when '黑米' then '黑米.jpg'
    when '红米' then '红米.jpg'
    when '大米' then '大米.jpg'
    when '小米' then '小米.jpg'
    when '大麦' then '大麦.jpg'
    when '小麦' then '小麦.jpg'
    when '燕麦' then '燕麦.jpg'
    when '荞麦' then '荞麦.jpg'
    when '黑麦' then '黑麦.jpg'
    when '其他麦类' then '其他麦类.jpg'
    when '玉米' then '玉米.jpg'
    when '红高粱' then '红高粱.jpg'
    when '白高粱' then '白高粱.jpg'
    when '薏仁米' then '薏仁米.jpg'
    when '白芝麻' then '白芝麻.jpg'
    when '黑芝麻' then '黑芝麻.jpg'
    when '亚麻籽' then '亚麻籽.jpg'
    when '花生米' then '花生米.jpg'
    when '其他米类' then '其他米类.jpg'
    when '冰糖' then '冰糖.jpg'
    when '梦缘' then '梦缘.jpg'
    when '三牛' then '三牛.jpg'
    when '味丹' then '味丹.jpg'
    when '金麟' then '金麟.jpg'
    when '沙琪玛' then '沙琪玛.jpg'
    when '其他饼干' then '其他饼干.jpg'
    when '浩客人家' then '浩客人家.jpg'
    when '达烽' then '达烽.jpg'
    when '鼎诚' then '鼎诚.jpg'
    when '蔡记' then '蔡记.jpg'
    when '蛋糕' then '蛋糕.jpg'
    when '米多奇' then '米多奇.jpg'
    when '友臣' then '友臣.jpg'
    when '芭比熊' then '芭比熊.jpg'
    when '碧根果' then '碧根果.jpg'
    when '开心果' then '开心果.jpg'
    when '巴旦木' then '巴坦木.jpg'
    when '花生类' then '花生.jpg'
    when '夏威夷果' then '夏威夷果.jpg'
    when '瓜子类' then '瓜子.jpg'
    when '核桃类' then '核桃.jpg'
    when '蚕豆类' then '蚕豆.jpg'
    when '松子类' then '松子.jpg'
    when '其他炒货' then '其他炒货.jpg'
    when '其他坚果' then '其他坚果.jpg'
    when '生瓜子 花生' then '生瓜子.jpg'
    when '包装果脯' then '包装果脯.jpg'
    when '包装豆干' then '包装豆干.jpg'
    when '包装坚果' then '包装坚果.jpg'
    when '散装肉制品' then '散装肉制品.jpg'
    when '小包装肉制品' then '小包装肉制品.jpg'
    when '蜜饯散装' then '蜜饯散装.jpg'
    when '山楂' then '山楂.jpg'
    when '蜜枣' then '蜜枣.jpg'
    when '新疆红枣' then '新疆大红枣.jpg'
    when '桂圆肉' then '桂圆肉.jpg'
    when '桂圆' then '桂圆.jpg'
    when '新疆葡萄干' then '新疆葡萄干.jpg'
    when '百合干' then '百合干.jpg'
    when '优质木耳' then '优质木耳.jpg'
    when '优质银耳' then '优质银耳.jpg'
    when '优质香菇' then '优质香菇.jpg'
    when '莲子' then '莲子.jpg'
    when '枸杞' then '枸杞.jpg'
    when '笋干' then '笋干.jpg'
    when '粉丝' then '粉丝.jpg'
    when '光明' then '光明.jpg'
    when '蒙牛' then '蒙牛.jpg'
    when '伊利' then '伊利.jpg'
    when '现代牧业' then '现代牧业.jpg'
    when '榨菜酱菜' then '榨菜酱菜.jpg'
    when '酱油' then '酱油.jpg'
    when '醋' then '醋.jpg'
    when '豆酱' then '豆酱.jpg'
    when '其他下饭菜' then '下饭菜.jpg'
    when '其他调味料' then '其他调味料.jpg'
    when '食盐味精' then '食盐味精.jpg'
    when '食用油' then '食用油.jpg'
    when '其他饮料' then '其他饮料.jpg'
    when '白酒' then '白酒.jpg'
    when '红牛' then '红牛.jpg'
    when '汇源' then '汇源.jpg'
    when '农夫果园' then '农夫果园.jpg'
    when '加多宝' then '加多宝.jpg'
    when '脉动' then '脉动.jpg'
    when '其他矿泉水' then '其他矿泉水.jpg'
    when '农夫山泉' then '农夫山泉.jpg'
    when '怡宝' then '怡宝.jpg'
    when '百岁山' then '百岁山.jpg'
    when '雀巢' then '雀巢.jpg'
    when '冰露' then '冰露.jpg'
    when '娃哈哈' then '娃哈哈.jpg'
    when '啤酒' then '啤酒.jpg'
    when '黄酒' then '黄酒.jpg'
    when '葡萄酒' then '葡萄酒.jpg'
    when '其他美酒' then '其他美酒.jpg'
    when '美味可乐' then '可乐.jpg'
    when '德芙' then '德芙.jpg'
    when '费列罗' then '费列罗.jpg'
    when '士力架' then '士力架.jpg'
    when '其他巧克力' then '其他巧克力.jpg'
    when '软糖' then '软糖.jpg'
    when '硬糖' then '硬糖.jpg'
    when '其他糖果' then '其他糖果.jpg'
    when "M&M'S" then 'mms.jpg'
    when '勿忘我' then '勿忘我.jpg'
    when '铁观音' then '铁观音.jpg'
    when '龙井绿茶' then '绿茶.jpg'
    when '工夫红茶' then '工夫红茶.jpg'
    when '芋香奶茶' then '芋香奶茶.jpg'
    when '拿铁咖啡' then '拿铁咖啡.jpg'
    when '补血草' then '补血草.jpg'
    when '红玫瑰' then '红玫瑰.jpg'
    when '57度' then '57度.jpg'
    when '光友' then '光友.jpg'
    when '今麦郎' then '今麦郎.jpg'
    when '农心' then '农心.jpg'
    when '五谷道场' then '五谷道场.jpg'
    when '其他速食' then '其他素食.jpg'
    when '其他面类' then '其他方便面.jpg'
    when '双汇' then '双汇.jpg'
    when '金锣' then '金锣.jpg'
    when '奶茶' then '奶茶.jpg'
    when '可比克' then '可比克.jpg'
    when '康师傅' 
      if sub_name == '饮料'
        '康师傅.jpg'
      elsif sub_name == '矿泉水'
        '康师傅矿泉水.jpg'
      elsif sub_name == '方便面'
        '康师傅方便面.jpg'
      end
    when '统一'
      if sub_name == '饮料'
        '统一.jpg'
      elsif sub_name == '方便面'
        '统一方便面.jpg'
      end
    end
  end
end
