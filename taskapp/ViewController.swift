import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //Realmインスタンス取得
    let realm = try! Realm()
    var task:Task!
    
    //DB内のタスクが格納されるリスト　日付未来順ソート：降順
    let taskArray = try! Realm().objects(Task).sorted("date", ascending: false)
    
    //検索カテゴリー表示用リスト　日付未来順ソート：降順
    var categoryArray = try! Realm().objects(Task).sorted("date", ascending: false)
    
    //検索カテゴリー表示用フラグ
    var categoryFlg: Int = 0
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 検索バー初期表示文設定
        searchBar.placeholder = "ここに入力してください"
        searchBar.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //サーチバーが更新されたとき
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        categoryFlg = 0
        tableView.reloadData()
    }
    
    //サーチバーがキャンセルされたとき
    //func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    //}
    
    //サーチバーで検索をしたとき
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {

        // 文字列で検索、日付未来順ソート：降順
        //let filterString = String("category = '\(searchBar.text!)'")
        categoryArray = realm.objects(Task).filter("category = '\(searchBar.text!)'").sorted("date", ascending: false)

        categoryFlg = 1
        dismissKeyboard()
        tableView.reloadData()
    }
    

    //tableView①　初期表示、再読み込みの際必ず処理される　データ数（セル数）返却
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(categoryFlg == 1){
            return categoryArray.count
        } else {
           return taskArray.count
        }
    }
    
    //tableView②　初期表示、再読み込みの際必ず処理される　データ内容返却　データ数と処理回数が同じ
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //再利用可能なcell取得
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        var task: AnyObject?
        
        //検索カテゴリー表示
        if(categoryFlg == 1){
            task = categoryArray[indexPath.row]
        } else {
            task = taskArray[indexPath.row]
        }

        cell.textLabel?.text = task!.title
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString: String = formatter.stringFromDate((task?.date)!)
        cell.detailTextLabel?.text = dateString
        return cell
    }
    
    //tableView③ 各セルを選択したとき
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("cellSegue",sender: nil)
    }
    
    //セルが削除が可能なことを伝える
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath)-> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    //Deleteボタンが押されたとき
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            //ローカル通知をキャンセルする
            let task = taskArray[indexPath.row]
            
            for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
                if notification.userInfo!["id"] as! Int == task.id {
                    UIApplication.sharedApplication().cancelLocalNotification(notification)
                    break
                }
            }
            
            //データベースから削除する
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }
    }
    
    //画面遷移するとき
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        let inputViewController:InputViewController = segue.destinationViewController as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            task.date = NSDate()
            
            if taskArray.count != 0 {
                task.id = taskArray.max("id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    
    //入力画面から戻ってきたときにTableViewを更新
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
}











