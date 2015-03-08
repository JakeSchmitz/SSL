require 'mongo'
include Mongo

class DocController < ApplicationController
	def index
		@filters = filters
		@docs = ssl.find(@filters).sort({"id" => 1})
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
			if params.has_key?(:title) and params[:title].match(/^[[:alnum:]]+$/)
				flts["ssltitle"] = Regexp.new(params[:title])
			end
			if params.has_key?(:author) and params[:author].match(/^[[:alnum:]]+$/)
				flts["sslauthor"] = Regexp.new(params[:author])
			end
			if params.has_key?(:keywords) and params[:keywords].match(/^[[:alnum:]]+$/)
				flts["u'subject_terms'"] = Regexp.new(params[:keywords])
			end
			if params.has_key?(:disciplines) and params[:disciplines].match(/^[[:alnum:]]+$/)
				flts["u'disciplines'"] = Regexp.new(params[:disciplines])
			end
			if params.has_key?(:publisher) and params[:publisher].match(/^[[:alnum:]]+$/)
				flts["u'publisher'"] = Regexp.new(params[:publisher])
			end
			flts
		end
end
