require 'spec_helper'

module Galago
  describe Router do
    let(:router) { Class.new(Router) }

    describe '.call' do
      it 'tells the router to process the request' do
        expect(router.router).to receive(:process_request).with('env')
        router.call('env')
      end
    end

    describe '.routes' do
      it 'adds the specified routes' do
        router.routes do
          get    '/foo' , to: lambda { |env| 'bar' }
          post   '/foo' , to: lambda { |env| 'bar' }
          patch  '/foo' , to: lambda { |env| 'bar' }
          put    '/foo' , to: lambda { |env| 'bar' }
          delete '/foo' , to: lambda { |env| 'bar' }
        end

        expect(router.router).to have_route(:get, '/foo')
        expect(router.router).to have_route(:post, '/foo')
        expect(router.router).to have_route(:patch, '/foo')
        expect(router.router).to have_route(:put, '/foo')
        expect(router.router).to have_route(:delete, '/foo')
      end
    end

    describe '.router' do
      it 'builds an instance if the router' do
        expect(router.router).to be_a Router
      end

      it 'remembers the router that was built' do
        router_id = router.router.object_id
        expect(router.router.object_id).to eql router_id
      end
    end

    describe "#add_route" do
      let(:rack_app) do
        lambda { |env| "RackApp" }
      end

      it "stores the route" do
        router = Router.new
        router.add_route(:get, '/users', rack_app)

        expect(router).to have_route(:get, '/users')
      end

      it "raises an error when an invalid http verb is provided" do
        router = Router.new

        expect { router.add_route(:foo, '/foo', rack_app)
        }.to raise_error Router::RequestMethodInvalid
      end
    end

    describe "has_route?" do
      it "returns true when the route has been added" do
        router = Router.new
        router.add_route(:post, '/users', lambda {})

        expect(router).to have_route(:post, '/users')
      end

      it "returns true when the route has a path param" do
        router = Router.new
        router.add_route(:get, '/users/:id', lambda {})

        expect(router).to have_route(:get, '/users/42')
      end

      it "returns false when the route has not been added" do
        router = Router.new
        router.add_route(:post, '/users', lambda {})

        expect(router).not_to have_route(:get, '/users')
      end
    end

    describe "process_request" do
      it "calls the rack app when the route is found" do
        router = Router.new
        router.add_route(:get, '/foo', lambda { |env| [200, {}, 'bar'] })

        response = router.process_request({
          'REQUEST_METHOD' => 'GET',
          'PATH_INFO' => '/foo'
        })

        expect(response).to eql [200, {}, 'bar']
      end

      it "returns 404 when no route matchs the path" do
        router = Router.new

        response = router.process_request({
          'REQUEST_METHOD' => 'GET',
          'PATH_INFO' => '/bar'
        })

        expect(response[0]).to eql(404)
        expect(response[1]).to eql({ 'Content-Length' => '9' })
        expect(response[2].body).to eql(['Not Found'])
      end
    end

  end
end
