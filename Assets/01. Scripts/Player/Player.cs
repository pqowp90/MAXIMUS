using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.SceneManagement;
using DG.Tweening;

public class Player : MonoBehaviour, IDamageable
{
    private float _hp = 100;
    private float _maxHp = 100;
    public float Health { get => _hp; set => _hp = value; }
    public float MaxHealth => _maxHp;

    private bool _isOpenBag;
    public ItemDB inventory;
    public PlayerAttack attack;
    public PlayerMovement playerMove;


    [Header("Item")]
    [SerializeField] private LayerMask _itemLayer;
    [SerializeField] private float _itemFindRadius = 1f;

    #region Mining
    [Header("Ore")]
    [SerializeField] private LayerMask _oreLayer;
    [SerializeField] private float _oreSearchRadius = 5f;

    private Ore mineOre;
    private RaycastHit mineHit;
    
    public bool isMine = false;
    private bool _isFindOre = false;
    private bool _isMining = false;
    #endregion

    [Header("Keybinds")]
    public KeyCode bagOpenKey = KeyCode.E;
    public KeyCode miningKey = KeyCode.F;

    [Header("Sound")]
    [SerializeField] private AudioClip _mineAttack;
    [SerializeField] private AudioClip _mineBreak;

    public UnityEvent<float> OnDamageTaken { get; set; }

    private void Start()
    {
        attack = GetComponent<PlayerAttack>();
        playerMove = GetComponent<PlayerMovement>();
       _hp = _maxHp;
       UIManager.Instance.HelathBarInit();

       PoolManager.CreatePool<PoolingEffect>("MineAttackEffect", ItemManager.Instance.poolObj, 10);
       PoolManager.CreatePool<PoolingEffect>("MineBreakEffect", ItemManager.Instance.poolObj, 10);
    }

    private void Update()
    {
        SearchItem();
        SearchOre();
        SwapBullet();
        
        if (Input.GetButton("Fire1") && Time.timeScale != 0)
        {
            Attak();
        }

        if (Input.GetButton("Fire2") && Time.timeScale != 0)
        {
            attack.ShoulderHold(true);
        }

        if(Input.GetButtonUp("Fire2") && Time.timeScale != 0)
        {
            attack.ShoulderHold(false);
        }

        if(Input.GetKeyUp(miningKey))
        {
            if(_isFindOre == true)
            {
                MineMod(true);
                UIManager.Instance.MessageDown();
            }
        }
        if(Input.GetKeyDown(KeyCode.Escape))
        {
            if(UIManager.Instance.isOption) MenuUi.Instance.Option(false);
            else UIManager.Instance.PauseMenu();
        }
    }

    private void SwapBullet()
    {
        float wheelInput = Input.GetAxis("Mouse ScrollWheel");
        if (wheelInput == 0) return;
        BulletManager.Instance.SwapBullet(wheelInput > 0);
    }

    private void SearchItem()
    {
        Collider[] _item = Physics.OverlapSphere(transform.position, _itemFindRadius, _itemLayer);
        if (_item.Length > 0)
        {
            Dictionary<string, List<DropItem>> itemList = new Dictionary<string, List<DropItem>>();
            foreach (var item in _item)
            {
                DropItem dropItem = item.transform.parent.GetComponent<DropItem>();
                if(dropItem.isEntering) continue;

                if(itemList.ContainsKey(dropItem.item.name))
                {
                    itemList[dropItem.item.name].Add(dropItem);
                }
                else
                {
                    itemList.Add(dropItem.item.name, new List<DropItem>());
                    itemList[dropItem.item.name].Add(dropItem);
                }
            }

            foreach(var item in itemList)
            {
                item.Value.ForEach(X => X.isEntering = true);
                ItemManager.Instance.GetItem(item.Value, item.Value.Count);
            }
        }
    }

    private void SearchOre()
    {
        if(Physics.Raycast(transform.position, transform.forward + new Vector3(0, 0.5f, 0), out mineHit, _oreSearchRadius, _oreLayer))
        {
            if(!isMine && !_isFindOre)
            {
                UIManager.Instance.Message($"[{miningKey}] MineMod");
                mineOre = mineHit.transform.GetComponent<Ore>();
                _isFindOre = true;
            }
        }
        else
        {
            if(isMine == true)
            {
                MineMod(false);
            }
            UIManager.Instance.MessageDown();
        }
    }

    private void MineMod(bool value)
    {
        _isFindOre = false;
        _isMining = false;
        isMine = value;
        
        SlotType type = SlotType.Skill;
        if(isMine == false)
            type = SlotType.Bullet;

        UIManager.Instance.SlotInit(type);
        UIManager.Instance.MessageDown();
    }

    private void Attak()
    {
        if(isMine)
        {
            if(_isMining == false)
            {
                playerMove.animator.SetTrigger("Mine");
                _isMining = true;
            }
            return;
        }

        if (attack.bullet == null || attack.bullet.Ammo == 0) return;

        if (!attack.AttackPossible)
        {
            attack.Attack();
        }
    }

    public void Mine()
    {
        _isMining = false;

        PoolingEffect effect;
        if(mineOre.Health - 1 == 0)
        {
            SoundManager.Instance.PlayClip(SoundType.EFFECT, _mineBreak);
            effect = PoolManager.GetItem<PoolingEffect>("MineBreakEffect");
            effect.transform.position = mineOre.transform.position;
        }
        mineOre.TakeDamage(1);
        ItemManager.Instance.DropItem(mineOre.transform.position, mineOre.data.dropItem, 1);
        SoundManager.Instance.PlayClip(SoundType.EFFECT, _mineAttack);

        effect = PoolManager.GetItem<PoolingEffect>("MineAttackEffect");
        effect.transform.position = mineHit.point;
    }


    public void TakeDamage(float damage)
    {
        _hp -= damage;
        UIManager.Instance.HealthBarReload();
        UIManager.Instance.ScreenDamage();
        UIManager.Instance.Popup(transform, damage.ToString(), true);
        Camera.main.DOShakeRotation(0.2f, new Vector3(10, 10), 50, 360);

        if(_hp <= 0)
        {
            playerMove.animator.SetTrigger("Die");
        }
    }
}
