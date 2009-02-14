require File.dirname(__FILE__) + '/../spec_helper'

describe Role do
  before(:each) do
    @role = Role.new
  end

  it "should be valid" do
    @role.should be_valid
  end

  describe 'load_roles' do
    before(:all) do
      @flat = "---\n- foo\n- bar\n- baz\n"
    end

    before(:each) do
      @owner = mock_model(Role, :name => 'owner')
      Role.stub!(:find_by_name).with('owner').and_return(@owner)
      Role.stub!(:create!)
    end

    it 'should load the YAML file specified' do
      YAML.should_receive(:load).with(:file).and_return([])
      Role.stub!(:initialize_roles).and_return([[], true])
      Role.stub!(:create_or_update_role)

      Role.load_roles(:file)
    end

    it "should set 'owner' as the implicit root owner if it is not specified explicitly" do
      foo = mock_model(Role, :name => 'foo')
      bar = mock_model(Role, :name => 'bar')
      baz = mock_model(Role, :name => 'baz')

      Role.should_receive(:initialize_roles).with(%w{foo bar baz}, nil).and_return([[foo, bar, baz], false])
      Role.should_receive(:create_or_update_role).with('owner', nil).and_return(:owner)

      [foo, bar, baz].each do |role|
        role.should_receive(:parent=).with(:owner)
        role.should_receive(:save!)
      end

      Role.load_roles(@flat)
    end

    it "should not set 'owner' as the implicit root owner if it is specified explicitly" do
      foo = mock_model(Role, :name => 'foo')
      bar = mock_model(Role, :name => 'bar')
      baz = mock_model(Role, :name => 'baz')

      Role.should_receive(:initialize_roles).with(%w{foo bar baz}, nil).and_return([[foo, bar, baz], true])
      Role.should_not_receive(:create_or_update_role).with('owner', anything)

      Role.load_roles(@flat)
    end
  end

  describe :initialize_roles do
    it 'should create each role in the array with the parent specified' do
      Role.should_receive(:create_or_update_role).with('foo', @owner)
      Role.should_receive(:create_or_update_role).with('bar', @owner)
      Role.should_receive(:create_or_update_role).with('baz', @owner)

      Role.initialize_roles(%w{foo bar baz}, @owner)
    end

    it 'should handle multiple children of a single role' do
      Role.should_receive(:create_or_update_role).ordered.with('foo', :parent).and_return(:foo)
      Role.should_receive(:create_or_update_role).ordered.with('bar', :foo)
      Role.should_receive(:create_or_update_role).ordered.with('baz', :foo)

      Role.initialize_roles([{'foo' => %w{bar baz}}], :parent)
    end

    it 'should handle multiple levels of hierarchical relationships' do
      Role.should_receive(:create_or_update_role).ordered.with('foo', nil).and_return(:foo)
      Role.should_receive(:create_or_update_role).ordered.with('bar', :foo).and_return(:bar)
      Role.should_receive(:create_or_update_role).ordered.with('baz', :bar).and_return(:baz)

      Role.initialize_roles([{"foo"=>[{"bar"=>["baz"]}]}], nil)
    end

    it 'should return the roles it created at the top level' do
      Role.should_receive(:create_or_update_role).with('foo', @owner).and_return(:foo)
      Role.should_receive(:create_or_update_role).with('bar', @owner).and_return(:bar)
      Role.should_receive(:create_or_update_role).with('baz', @owner).and_return(:baz)

      Role.initialize_roles(%w{foo bar baz}, @owner).first.should == [:foo, :bar, :baz]
    end

    it 'should return a second value of true if the owner role was created' do
      Role.should_receive(:create_or_update_role).with('owner', nil).and_return(:owner)
      Role.should_receive(:create_or_update_role).with('foo', :owner).and_return(:foo)
      Role.should_receive(:create_or_update_role).with('bar', :owner).and_return(:bar)
      Role.should_receive(:create_or_update_role).with('baz', :owner).and_return(:baz)

      Role.initialize_roles([{'owner' => %w{foo bar baz}}], nil)[1].should == true
    end

    it 'should return a second value of true if the owner role was created below the top level' do
      Role.should_receive(:create_or_update_role).with('foo', nil).and_return(:foo)
      Role.should_receive(:create_or_update_role).with('owner', :foo).and_return(:owner)
      Role.should_receive(:create_or_update_role).with('bar', :foo).and_return(:bar)
      Role.should_receive(:create_or_update_role).with('baz', :foo).and_return(:baz)

      Role.initialize_roles([{'foo' => %w{owner bar baz}}], nil)[1].should == true
    end

    it 'should return a second value of false if the owner role was not created' do
      Role.should_receive(:create_or_update_role).with('foo', nil).and_return(:foo)
      Role.should_receive(:create_or_update_role).with('bar', nil).and_return(:bar)
      Role.should_receive(:create_or_update_role).with('baz', nil).and_return(:baz)

      Role.initialize_roles(%w{foo bar baz}, nil)[1].should == false
    end
  end

  describe :create_or_update_role do
    before(:each) do
      @foo = mock_model(Role, :name => 'foo', :parent => nil, :parent_id => nil)
      @bar = mock_model(Role, :name => 'foo', :parent => @foo, :parent_id => @foo.id)
    end

    it 'should return the role if it exists and has the correct non-nil parent' do
      Role.should_receive(:find_by_name).with('bar').and_return(@bar)

      Role.create_or_update_role('bar', @foo).should == @bar
    end

    it 'should return the role if it exists and has the correct nil parent' do
      Role.should_receive(:find_by_name).with('foo').and_return(@foo)

      Role.create_or_update_role('foo', nil).should == @foo
    end

    it 'should create the role with the specified parent if it does not exist' do
      Role.should_receive(:find_by_name).with('foo').and_return(nil)
      Role.should_receive(:create!).with(:name => 'foo', :parent => :foo_parent).and_return(@foo)

      Role.create_or_update_role('foo', :foo_parent).should == @foo
    end

    it 'should update the role to the specified parent if it exists and does not have the correct nil parent' do
      Role.should_receive(:find_by_name).with('bar').and_return(@bar)
      @bar.should_receive(:parent=).with(nil)
      @bar.should_receive(:save!)

      Role.create_or_update_role('bar', nil).should == @bar
    end

    it 'should update the role to the specified parent if it exists and does not have the correct non-nil parent' do
      Role.should_receive(:find_by_name).with('bar').and_return(@bar)
      @bar.stub!(:parent).and_return(nil)
      @bar.should_receive(:parent=).with(@foo)
      @bar.should_receive(:save!)

      Role.create_or_update_role('bar', @foo).should == @bar
    end
  end
end
