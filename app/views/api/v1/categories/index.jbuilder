if @categories
  json.errcode 0
  json.errmsg '获取大分类成功'
  json.obj do
    json.categorylist(@categories) do |category|
      json.id category.id
      json.name category.name
    end
    json.objlist(@category.sub_categories.normal.sorted) do |sub_category|
      json.id sub_category.id
      json.name sub_category.name
      json.set! 'list' do
        detail_categories = sub_category.detail_categories.normal.sorted
        json.array! detail_categories do |detail_category|
          json.id detail_category.id
          json.name detail_category.name
          json.image detail_category.key.try(:url)
        end
      end
    end
  end
else
  json.errcode 1
  json.errmsg '获取大分类失败'
  json.obj do
  end
end
