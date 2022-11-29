using System.Diagnostics.CodeAnalysis;
using UnityEngine;
using UnityEngine.SceneManagement;

[SuppressMessage("ReSharper", "StaticMemberInGenericType")]
public class MonoSingleton<T> : MonoBehaviour where T : MonoBehaviour
{
    public static bool IsInitialized => _instance != null;
    private static T _instance;
    private static readonly object Lock = new();
    private static bool _applicationIsQuitting;
    private static bool _isDontDestroyOnLoad;

    public static T Instance
    {
        get
        {
            if (_applicationIsQuitting)
            {
                Debug.LogWarning(
                    $"[MonoSingleton] Instance '{typeof(T)}' already destroyed on application quit. Won't create again - returning null.");
                return null;
            }

            lock (Lock)
            {
                if (!ReferenceEquals(_instance, null)) return _instance;

                _instance = (T)FindObjectOfType(typeof(T));

                if (FindObjectsOfType(typeof(T)).Length > 1)
                {
                    Debug.LogError($"[Singleton] {typeof(T)} More than one instance of singleton found!");
                    return _instance;
                }

                if (_instance == null)
                {
                    var singleton = new GameObject();
                    _instance = singleton.AddComponent<T>();
                    singleton.name = "(singleton) " + typeof(T);

                    if (_isDontDestroyOnLoad) DontDestroyOnLoad(singleton);

                    Debug.Log(
                        $"[Singleton] An instance of {typeof(T)} is needed in the scene, so '{singleton}' was created.");
                }
                else
                {
                    Debug.Log($"[Singleton] Using instance already created: {_instance.gameObject.name}");
                }

                return _instance;
            }
        }
    }

    public virtual void Awake()
    {
        if (_instance == null)
        {
            _instance = this as T;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }

    private void OnEnable()
    {
        _isDontDestroyOnLoad =
            typeof(T).GetCustomAttributes(typeof(DontDestroyOnLoadAttribute), true).Length > 0;

        if (_isDontDestroyOnLoad)
            DontDestroyOnLoad(this);
        else
            SceneManager.sceneUnloaded += OnSceneUnloaded;
    }

    public virtual void OnDestroy()
    {
        _applicationIsQuitting = true;
    }

    private void OnSceneUnloaded(Scene scene)
    {
        if (!_isDontDestroyOnLoad) _instance = null;
    }
}