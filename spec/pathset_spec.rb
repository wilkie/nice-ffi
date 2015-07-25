require 'spec_helper.rb'

describe NiceFFI::PathSet do
  describe "by default" do

    before :each do
      @pathset = NiceFFI::PathSet.new()
    end

    it "should have no paths" do
      expect(@pathset.paths).to eq({})
    end

    ##########
    # APPEND #
    ##########

    describe "appending paths" do
      describe "in place" do
        it "should return self" do
          paths = { /a/ => ["b"], /c/ => ["d"] }
          expect(@pathset.append!(paths)).to eq(@pathset)
        end

        it "should add them" do
          paths = { /a/ => ["b"], /c/ => ["d"] }
          @pathset.append!( paths )
          expect(@pathset.paths).to eq({ /a/ => ["b"], /c/ => ["d"] })
        end
      end

      describe "in a dup" do
        before :each do
          @ps = @pathset.append( /a/ => ["b"], /c/ => ["d"] )
        end

        it "should return a dup" do
          expect(@ps).to_not be(@pathset)
        end

        it "should add them" do
          expect(@ps.paths).to eq({ /a/ => ["b"], /c/ => ["d"] })
        end
      end
    end # appending

    ###########
    # PREPEND #
    ###########

    describe "prepending paths" do
      describe "in place" do
        it "should return self" do
          paths = { /a/ => ["b"], /c/ => ["d"] }
          expect(@pathset.prepend!(paths)).to be(@pathset)
        end

        it "should add them" do
          paths = { /a/ => ["b"], /c/ => ["d"] }
          @pathset.prepend!( paths )
          expect(@pathset.paths).to eq({ /a/ => ["b"], /c/ => ["d"] })
        end
      end

      describe "in a dup" do
        before :each do
          @ps = @pathset.prepend( /a/ => ["b"], /c/ => ["d"] )
        end

        it "should return a dup" do
          expect(@ps).to_not be(@pathset)
        end

        it "should add them" do
          expect(@ps.paths).to eq({ /a/ => ["b"], /c/ => ["d"] })
        end
      end
    end # prepending

    ###########
    # REPLACE #
    ###########

    describe "replacing paths" do
      describe "in place" do
        it "should return self" do
          paths = { /a/ => ["e"], /c/ => ["f"] }
          expect(@pathset.replace!(paths)).to be(@pathset)
        end

        it "should add the new paths" do
          paths = { /a/ => ["e"], /c/ => ["f"] }
          @pathset.replace!( paths )
          expect(@pathset.paths).to eq({ /a/ => ["e"], /c/ => ["f"] })
        end
      end

      describe "in a dup" do
        before :each do
          @ps = @pathset.replace( /a/ => ["e"], /c/ => ["f"] )
        end

        it "should return a dup" do
          expect(@ps).to_not be(@pathset)
        end

        it "should add the new paths" do
          expect(@ps.paths).to eq({ /a/ => ["e"], /c/ => ["f"] })
        end
      end

    end # replacing

    ##########
    # REMOVE #
    ##########

    describe "removing paths" do
      describe "in place" do
        it "should return self" do
          paths = { /a/ => ["b"], /c/ => ["f"] }
          expect(@pathset.remove!(paths)).to be(@pathset)
        end

        it "should have no effect" do
          paths = { /a/ => ["b"], /c/ => ["f"] }
          @pathset.remove!( paths )
          expect(@pathset.paths).to eq({})
        end
      end

      describe "in a dup" do
        before :each do
          @ps = @pathset.remove( /a/ => ["b"], /c/ => ["f"] )
        end

        it "should return a dup" do
          expect(@ps).to_not be(@pathset)
        end

        it "should have no effect" do
          expect(@ps.paths).to eq({})
        end
      end
    end # removing

    ##########
    # DELETE #
    ##########

    describe "deleting" do
      describe "in place" do
        it "should return self" do
          expect(@pathset.delete!( /a/, /b/ )).to be(@pathset)
        end

        it "should have no effect" do
          @pathset.delete!( /a/, /b/ )
          expect(@pathset.paths).to eq({})
        end
      end

      describe "in a dup" do
        before :each do
          @ps = @pathset.delete( /a/, /c/ )
        end

        it "should return a dup" do
          expect(@ps).to_not be(@pathset)
        end

        it "should have no effect" do
          expect(@ps.paths).to eq({})
        end
      end
    end # deleting
  end # by default

  describe "made with paths" do
    before :each do
      @pathset = NiceFFI::PathSet.new( /a/ => ["b"], /c/ => ["d"] )
    end

    it "should have those paths" do
      expect(@pathset.paths).to eq({ /a/ => ["b"], /c/ => ["d"] })
    end
  end

  describe "with paths" do
    before :each do
      @pathset = NiceFFI::PathSet.new( /a/ => ["b"], /c/ => ["d"] )
    end

    ##########
    # APPEND #
    ##########

    describe "appending paths" do
      describe "in place" do
        it "should return self" do
          paths = { /a/ => ["e"], /c/ => ["f"] }
          expect(@pathset.append!(paths)).to be(@pathset)
        end

        it "should append-merge them" do
          paths = { /a/ => ["e"], /c/ => ["f"] }
          @pathset.append!( paths )
          expect(@pathset.paths).to eq({ /a/ => ["b", "e"], /c/ => ["d", "f"] })
        end
      end

      describe "in a dup" do
        before :each do
          @ps = @pathset.append( /a/ => ["e"], /c/ => ["f"] )
        end

        it "should return a dup" do
          expect(@ps).to_not be(@pathset)
        end

        it "should append-merge them" do
          expect(@ps.paths).to eq({ /a/ => ["b", "e"], /c/ => ["d", "f"] })
        end
      end
    end # appending

    ###########
    # PREPEND #
    ###########

    describe "prepending paths" do
      describe "in place" do
        it "should return self" do
          paths = { /a/ => ["e"], /c/ => ["f"] }
          expect(@pathset.prepend!(paths)).to be(@pathset)
        end

        it "should prepend-merge them" do
          paths = { /a/ => ["e"], /c/ => ["f"] }
          @pathset.prepend!( paths )
          expect(@pathset.paths).to eq({ /a/ => ["e", "b"], /c/ => ["f", "d"] })
        end
      end

      describe "in a dup" do
        before :each do
          @ps = @pathset.prepend( /a/ => ["e"], /c/ => ["f"] )
        end

        it "should return a dup" do
          expect(@ps).to_not be(@pathset)
        end

        it "should prepend-merge them" do
          expect(@ps.paths).to eq({ /a/ => ["e", "b"], /c/ => ["f", "d"] })
        end
      end
    end # prepending

    ###########
    # REPLACE #
    ###########

    describe "replacing paths" do
      describe "in place" do
        it "should return self" do
          paths = { /a/ => ["e"], /c/ => ["f"] }
          expect(@pathset.replace!(paths)).to be(@pathset)
        end

        it "should replace the old paths" do
          paths = { /a/ => ["e"], /c/ => ["f"] }
          @pathset.replace!( paths )
          expect(@pathset.paths).to eq({ /a/ => ["e"], /c/ => ["f"] })
        end
      end

      describe "in a dup" do
        before :each do
          @ps = @pathset.replace( /a/ => ["e"], /c/ => ["f"] )
        end

        it "should return a dup" do
          expect(@ps).to_not be(@pathset)
        end

        it "should replace the old paths" do
          expect(@ps.paths).to eq({ /a/ => ["e"], /c/ => ["f"] })
        end
      end
    end # replacing

    ##########
    # REMOVE #
    ##########

    describe "removing paths" do
      before :each do
        @pathset = NiceFFI::PathSet.new( /a/ => ["b", "e"],
                                         /c/ => ["d", "f"] )
      end

      describe "in place" do
        it "should return self" do
          paths = { /a/ => ["b"], /c/ => ["f"] }
          expect(@pathset.remove!(paths)).to be(@pathset)
        end

        it "should remove them" do
          paths = { /a/ => ["b"], /c/ => ["f"] }
          @pathset.remove!( paths )
          expect(@pathset.paths).to eq({ /a/ => ["e"], /c/ => ["d"] })
        end

        it "should remove the key if no paths are left" do
          @pathset = NiceFFI::PathSet.new( /a/ => ["b"], /c/ => ["d"] )
          paths = { /a/ => ["b"] }
          @pathset.remove!( paths )
          expect(@pathset.paths).to_not have_key(/a/)
        end
      end

      describe "in a dup" do
        before :each do
          @ps = @pathset.remove( /a/ => ["e"], /c/ => ["f"] )
        end

        it "should return a dup" do
          expect(@ps).to_not be(@pathset)
        end

        it "should remove them" do
          expect(@ps.paths).to eq({ /a/ => ["b"], /c/ => ["d"] })
        end

        it "should remove the key if no paths are left" do
          @pathset = NiceFFI::PathSet.new( /a/ => ["b"], /c/ => ["d"] )
          @ps = @pathset.remove!( /a/ => ["b"] )
          expect(@ps.paths).to eq({ /c/ => ["d"] })
        end
      end
    end # removing

    ##########
    # DELETE #
    ##########

    describe "deleting paths" do
      before :each do
        @pathset = NiceFFI::PathSet.new( /a/ => ["b"],
                                         /c/ => ["d"],
                                         /e/ => ["f"])
      end

      describe "in place" do
        it "should return self" do
          expect(@pathset.delete!( /a/, /c/ )).to be(@pathset)
        end

        it "should remove the keys" do
          @pathset.delete!( /a/, /c/ )
          expect(@pathset.paths).to eq({ /e/ => ["f"] })
        end
      end

      describe "in a dup" do
        before :each do
          @ps = @pathset.delete( /a/, /c/ )
        end

        it "should return a dup" do
          expect(@ps).to_not be(@pathset)
        end

        it "should remove the keys" do
          expect(@ps.paths).to eq({ /e/ => ["f"] })
        end
      end
    end # deleting
  end # with paths
end # NiceFFI::PathSet
