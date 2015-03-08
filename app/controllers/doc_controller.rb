require 'mongo'
include Mongo

class DocController < ApplicationController
	def index
		@docs = ssl.find(filters).sort(:id)
	end

	def show
		@doc = ssl.find({ "id" => params[:id] }).to_a.first
	end

	private
		def ssl
			mongo_uri = ENV['SSL_MONGODB']
			db_name = mongo_uri[%r{/([^/\?]+)(\?|$)}, 1]
			client = MongoClient.from_uri(mongo_uri)
			db = client.db(db_name)
			db.collection('ssl')
		end

		def filters
			flts = {}
			if params.has_key?(:title)
				flts["ssltitle"] = Regexp.new(params[:title])
			end
			if params.has_key?(:author)
				flts["sslauthor"] = Regexp.new(params[:author])
			end
			flts
		end
end
