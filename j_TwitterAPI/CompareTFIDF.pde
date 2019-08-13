class CompareTFIDF implements Comparator<MyWord>
  {
    @Override
    public int compare(MyWord v1, MyWord v2)
    {
      return Float.compare(v2.tfidf,v1.tfidf);
    }
  }
