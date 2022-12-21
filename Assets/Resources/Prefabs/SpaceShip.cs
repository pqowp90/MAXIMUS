using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[System.Serializable]
public class GoalType
{
    public Item item = null;
    public int count = 0;
    public bool isGoal = false;
}
public class SpaceShip : MonoSingleton<SpaceShip>
{
    [SerializeField]
    private List<GoalType> inputItems = new List<GoalType>();
    private List<ItemSpace> inputItemSpaces = new List<ItemSpace>();
    [SerializeField]
    private List<Vector2Int> spaceShipRange = new List<Vector2Int>();

    public override void Awake() {
        base.Awake();
        foreach (var item in inputItems)
        {
            ItemSpace _inputSpace = gameObject.AddComponent<ItemSpace>();
            _inputSpace.canIn = true;
            _inputSpace.canOut = false;
            _inputSpace.spaceType = SpaceType.Connected;
            _inputSpace.connectSO = item.item;
            inputItemSpaces.Add(_inputSpace);
        }
        foreach (var pos in spaceShipRange)
        {
            GridManager.Instance.canInsertPoss.TryAdd(pos + new Vector2Int(500,500), new List<ItemSpace>());
            GridManager.Instance.canInsertPoss[pos + new Vector2Int(500,500)].AddRange(inputItemSpaces);
        }
    }
    public void ConnectItem(Item _item)
    {
        for (int i = 0; i < inputItems.Count; i++)
        {
            if(inputItems[i].item == _item)
            {
                if(inputItems[i].count <= _item.amount)
                {
                    inputItems[i].isGoal = true;
                }
            }
        }
        CheckGoal();
    }
    private bool theEnd;
    public void CheckGoal()
    {
        bool goal = true;
        foreach (var item in inputItems)
        {
            if(item.isGoal == false)
            {
                goal = false;
                break;
            }
        }
        if(goal == true)
        {
            Debug.Log("You Win");
            theEnd = true;
        }
    }
    private void OnDrawGizmos() {
        for (int i = 0; i < spaceShipRange.Count; i++)
        {
            Gizmos.color = Color.green;
            Gizmos.DrawWireSphere(new Vector3(spaceShipRange[i].x+500, 0, spaceShipRange[i].y+500), 0.1f);
        }
        
    }
}
