require 'awesome_print'
AwesomePrint.pry!
require 'jsonclient'
require 'mongo'
include Mongo

class DocController < ApplicationController
	def index
		@filters = filters
		@docs = ssl.find(@filters).sort(sorted_by)
	end

	def show
		@doc = ssl.find({id: params[:id]}).to_a.first
	end

        def find
                clnt = JSONClient.new
                header = {'Cookie' => 'Summon-Two=true'}
                response = clnt.get("http://tufts.summon.serialssolutions.com/api/search?pn=1&ho=t&q=" + params[:title],
                                    nil,
                                    header)
                json_response = response.content
                if json_response.keys.include?("documents")
                    @result = response.content["documents"]
                else
                    @result = nil
                end
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

		def sorted_by
			srt = {}
			if params.has_key?(:sort_by) and params[:sort_by].match(/^[[:alnum:]]+$/)
				srt[params[:sort_by]] = 1
			else
				srt[:ssltitle] = 1
			end
			srt
		end
end
