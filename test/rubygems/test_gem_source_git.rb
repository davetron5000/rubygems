require 'rubygems/test_case'
require 'rubygems/source'

class TestGemSourceGit < Gem::TestCase

  def setup
    super

    @name, @version, @repository, @head = git_gem

    @hash = Digest::SHA1.hexdigest @repository

    @source = Gem::Source::Git.new @name, @repository, 'master'
  end

  def test_checkout
    @source.cache

    @source.checkout

    assert_path_exists File.join @source.install_dir, 'a.gemspec'
  end

  def test_cache
    @source.cache

    assert_path_exists @source.repo_cache_dir

    Dir.chdir @source.repo_cache_dir do
      assert_equal @head, Gem::Util.popen(@git, 'rev-parse', 'master').strip
    end
  end

  def test_cache
    @source.cache

    assert @source.cache
  end

  def test_dir_shortref
    @source.cache

    assert_equal @head[0..11], @source.dir_shortref
  end

  def test_install_dir
    @source.cache

    expected = File.join Gem.dir, 'bundler', 'gems', "a-#{@head[0..11]}"

    assert_equal expected, @source.install_dir
  end

  def test_repo_cache_dir
    expected =
      File.join Gem.dir, 'cache', 'bundler', 'git', "a-#{@hash}"

    assert_equal expected, @source.repo_cache_dir
  end

  def test_rev_parse
    @source.cache

    assert_equal @head, @source.rev_parse
  end

  def test_update
    @source.update

    assert_path_exists File.join @source.install_dir, 'a.gemspec'
  end

  def test_uri_hash
    assert_equal @hash, @source.uri_hash

    source = Gem::Source::Git.new 'a', 'http://git@example/repo.git', 'master'

    assert_equal '291c4caac7feba8bb64c297987028acb3dde6cfe',
                 source.uri_hash

    source = Gem::Source::Git.new 'a', 'HTTP://git@EXAMPLE/repo.git', 'master'

    assert_equal '291c4caac7feba8bb64c297987028acb3dde6cfe',
                 source.uri_hash
  end

end

