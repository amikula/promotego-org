def mock_and_find(clazz, options={})
  retval = mock_model(clazz, options)
  clazz.stub!(:find).with(retval.id.to_s).and_return(retval)
  return retval
end
