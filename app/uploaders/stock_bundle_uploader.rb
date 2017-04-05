class StockBundleUploader < DocumentUploader
	def store_dir
		# /#{Rails.root}/
    "uploads/stock_bundles/#{model.id}"
  end

  def extension_white_list
    %w(csv)
  end
end
