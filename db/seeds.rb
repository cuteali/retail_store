# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

shop_model = ShopModel.where(name: '模板一').first_or_create
shop1 = Shop.where(name: '醉食汇高平路店', address: '上海市闸北区高平路779号', lng: '121.427466', lat: '31.290437', phone: '15026815026', director: '张明', shop_model_id: shop_model.id).first_or_create
shop2 = Shop.where(name: '醉食汇大连路店', address: '上海市虹口区大连路1035号', lng: '121.506019', lat: '31.268009', phone: '15026815026', director: '闫康', shop_model_id: shop_model.id).first_or_create
unit1 = Unit.where(name: '箱').first_or_create
unit2 = Unit.where(name: '包').first_or_create
category1 = Category.where(name: '牛奶饮品', name_as: '牛奶', key: '牛奶@2x.png', is_app_index: true).first_or_create
category2 = Category.where(name: '五谷杂粮', name_as: '杂粮', key: '杂粮@2x.png', is_app_index: true).first_or_create
category3 = Category.where(name: '饼干蛋糕', name_as: '饼干', key: '饼干@2x.png', is_app_index: true).first_or_create
category4 = Category.where(name: '零食休闲', name_as: '零食', key: '零食@2x.png', is_app_index: true).first_or_create
category5 = Category.where(name: '南北干货', name_as: '干货', key: '干货@2x.png', is_app_index: true).first_or_create
category6 = Category.where(name: '坚果炒货', name_as: '坚果', key: '坚果图@2x.png', is_app_index: true).first_or_create
category7 = Category.where(name: '美味糖果', name_as: '糖果', key: '糖果@2x.png', is_app_index: true).first_or_create
category8 = Category.where(name: '营养花茶', name_as: '花茶', key: '花茶@2x.png', is_app_index: true).first_or_create
category9 = Category.where(name: '酱菜调味').first_or_create
category10 = Category.where(name: '方便速食').first_or_create
category11 = Category.where(name: '饮料酒水').first_or_create
sub_category1 = category1.sub_categories.where(name: '光明').first_or_create
sub_category2 = category1.sub_categories.where(name: '蒙牛').first_or_create
detail_category1 = sub_category1.detail_categories.where(category_id: category1.id, name: '莫斯利安', key: '莫斯利安.jpg').first_or_create
detail_category2 = sub_category2.detail_categories.where(category_id: category1.id, name: '特仑苏', key: '特仑苏.jpg').first_or_create
product1 = shop1.shop_products.where(category_id: category1.id, sub_category_id: sub_category1.id, detail_category_id: detail_category1.id, unit_id: unit1.id,
                                      name: '莫斯利安12盒', price: 44, old_price: 46, stock_volume: 100, sales_volume: 0, key: '光明.jpg',
                                      desc: '莫斯利安', info: '莫斯利安', spec: '200g*12/箱', is_app_index: true).first_or_create
product2 = shop1.shop_products.where(category_id: category1.id, sub_category_id: sub_category1.id, detail_category_id: detail_category1.id, unit_id: unit1.id,
                                      name: '莫斯利安18杯', price: 45, old_price: 48, stock_volume: 99, sales_volume: 1, key: '光明.jpg',
                                      desc: '莫斯利安', info: '莫斯利安', spec: '110g*18杯/箱', is_app_index: true).first_or_create
product3 = shop1.shop_products.where(category_id: category1.id, sub_category_id: sub_category1.id, detail_category_id: detail_category1.id, unit_id: unit1.id,
                                      name: '优+礼盒', price: 35, old_price: 38, stock_volume: 100, sales_volume: 0, key: '光明.jpg',
                                      desc: '莫斯利安', info: '莫斯利安', spec: '250ml*12/箱', is_app_index: true).first_or_create
product4 = shop1.shop_products.where(category_id: category1.id, sub_category_id: sub_category2.id, detail_category_id: detail_category2.id, unit_id: unit1.id,
                                      name: '蒙牛特伦苏纯牛奶250ml', price: 48, old_price: 53, stock_volume: 100, sales_volume: 0, key: '光明.jpg',
                                      desc: '蒙牛', info: '蒙牛', spec: '250ml*12/箱', is_app_index: true).first_or_create
