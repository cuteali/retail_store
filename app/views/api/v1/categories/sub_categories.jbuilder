if @sub_categories
  json.errcode 0
  json.errmsg '获取小分类成功'
  json.objlist(@sub_categories) do |sub_category|
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
else
  json.errcode 1
  json.errmsg '获取小分类失败'
  json.objlist do
  end
end
