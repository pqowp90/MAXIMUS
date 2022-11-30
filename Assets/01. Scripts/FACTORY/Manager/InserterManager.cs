using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InserterManager : MonoBehaviour
{
    private List<Inserter> inserters = new List<Inserter>();
    public void AddInserter(Inserter _inserter)
    {
        inserters.Add(_inserter);
    }
    public void RemoveInserter(Inserter _inserter)
    {
        inserters.Remove(_inserter);
    }
    public void MoveInserter()
    {
        foreach (var item in inserters)
        {
            if(item.Item != null)
            {
                //item.Item.transform.position = item.transform.position;
            }
        }
    }
}
