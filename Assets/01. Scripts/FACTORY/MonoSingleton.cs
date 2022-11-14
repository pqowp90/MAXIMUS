using UnityEngine;

public class MonoSingleton<T> : MonoBehaviour where T : MonoSingleton<T>
{

    private static object locker = new object();
    private static T instance = null;
    
    public static T Instance
    {
        get
        {

            lock (locker)
            {
                if (instance == null)
                {
                    instance = FindObjectOfType<T>();
                    if (instance == null)
                    {
                        instance = new GameObject(typeof(T).ToString()).AddComponent<T>();
                        //DontDestroyOnLoad(instance);
                    }
                }
                return instance;
            }
        }
    }


}
