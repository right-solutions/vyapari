class Image::CategoryImage < Image::Base
	mount_uploader :image, CategoryImageUploader
end
