import json
import os
import sys


def find_file_in_directory(directory, filename):
    """Tìm file trong thư mục và các thư mục con"""
    for root, dirs, files in os.walk(directory):
        if filename in files:
            return os.path.join(root, filename)
    return None

def read_file_content(file_path):
    """Đọc nội dung file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return f.read()
    except Exception as e:
        print(f"❌ Lỗi khi đọc file {file_path}: {e}")
        return None

def write_file_content(file_path, content):
    """Ghi nội dung vào file"""
    try:
        # Tạo thư mục nếu chưa tồn tại
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    except Exception as e:
        print(f"❌ Lỗi khi ghi file {file_path}: {e}")
        return False



def scan_repositories_in_directory(target_base_path):
    """Quét và trả về danh sách repositories trong thư mục"""
    repositories = []
    
    if not os.path.exists(target_base_path):
        print(f"❌ Không tìm thấy thư mục: {target_base_path}")
        return repositories
    
    try:
        items = [item for item in os.listdir(target_base_path) if os.path.isdir(os.path.join(target_base_path, item))]
        print(f"📂 Tìm thấy {len(items)} thư mục trong {target_base_path}")
        
        for item in items:
            item_path = os.path.join(target_base_path, item)
            
            # Kiểm tra có phải git repository không
            git_path = os.path.join(item_path, ".git")
            if os.path.exists(git_path):
                repositories.append((item_path, item))
                print(f"  ✅ Git repository: {item}")
            else:
                print(f"  ⚠️ Không phải git repository: {item}")
                
    except Exception as e:
        print(f"❌ Lỗi khi đọc thư mục {target_base_path}: {e}")
    
    return repositories

def copy_file_to_repo(source_file_path, target_repo_path, filename, repo_name):
    """Copy file từ source sang target repository"""
    print(f"  📁 Đang xử lý {filename} cho {repo_name}...")
    
    # Đọc nội dung source file
    source_content = read_file_content(source_file_path)
    if source_content is None:
        print(f"    ❌ Không thể đọc source file")
        return False
    
    # Tìm file đích trong repository
    target_file_path = find_file_in_directory(target_repo_path, filename)
    
    if not target_file_path:
        print(f"    ⚠️ Không tìm thấy {filename} trong repository")
        # Thử tìm trong src folder
        src_path = os.path.join(target_repo_path, "src")
        if os.path.exists(src_path):
            target_file_path = find_file_in_directory(src_path, filename)
        
        if not target_file_path:
            print(f"    ❌ Không tìm thấy {filename} trong {repo_name}")
            return False
    
    print(f"    📍 Tìm thấy: {os.path.relpath(target_file_path, target_repo_path)}")
    
    final_content = source_content
    
    # Ghi file mới
    if write_file_content(target_file_path, final_content):
        print(f"    ✅ Đã replace {filename}")
        return True
    else:
        return False

def process_repository(source_files, target_repo_path, repo_name):
    """Xử lý một repository"""
    print(f"\n=== 📦 Đang xử lý repository: {repo_name} ===")
    
    success_count = 0
    total_files = len(source_files)
    
    for filename, source_path in source_files.items():
        if copy_file_to_repo(source_path, target_repo_path, filename, repo_name):
            success_count += 1
    
    print(f"📊 Kết quả: {success_count}/{total_files} files thành công")
    return success_count == total_files

def main():
    """Main function"""
    print("📁 === COPY & REPLACE CONFIG FILES SCRIPT ===")
    print("Mục tiêu: Copy AudioIds.ts, audio-config.json từ source repository sang tất cả target repositories")
    
    # Nhập đường dẫn source repository
    print("\n🔍 === NHẬP ĐƯỜNG DẪN SOURCE REPOSITORY ===")
    source_repo_input = input("📁 Nhập đường dẫn đến source repository (mặc định: ../slot-game/street-warrior-client): ").strip()
    
    if not source_repo_input:
        source_repo_path = os.path.join("..", "slot-game", "street-warrior-client")
    else:
        source_repo_path = source_repo_input
    
    # Chuyển đổi thành absolute path để dễ hiểu
    source_repo_path = os.path.abspath(source_repo_path)
    
    if not os.path.exists(source_repo_path):
        print(f"❌ Không tìm thấy source repository: {source_repo_path}")
        return
    
    print(f"✅ Source repository: {source_repo_path}")
    
    # Tìm các file cần copy
    target_files = ["AudioIds.ts", "audio-config.json"]
    source_files = {}
    
    print("\n🔍 === QUÉT SOURCE FILES ===")
    for filename in target_files:
        file_path = find_file_in_directory(source_repo_path, filename)
        if file_path:
            source_files[filename] = file_path
            relative_path = os.path.relpath(file_path, source_repo_path)
            print(f"  ✅ {filename}")
            print(f"      📍 {relative_path}")
        else:
            print(f"  ❌ Không tìm thấy: {filename}")
    
    if not source_files:
        print("❌ Không tìm thấy file nào để copy!")
        print("💡 Hãy kiểm tra lại đường dẫn source repository và đảm bảo có các files:")
        for filename in target_files:
            print(f"  - {filename}")
        return
    
    print(f"\n📋 Sẽ copy {len(source_files)}/{len(target_files)} files")
    
    # Nhập đường dẫn target repositories
    print("\n🎯 === NHẬP TARGET REPOSITORIES ===")
    print("💡 Bạn có thể nhập:")
    print("  1. Đường dẫn trực tiếp đến 1 repository")
    print("  2. Nhiều đường dẫn repositories (cách nhau bằng dấu ;)")
    print("  3. Đường dẫn thư mục chứa nhiều repositories")
    print("  4. Để trống để sử dụng mặc định: ../test-rename-sxf")
    
    target_input = input("\n📁 Nhập đường dẫn target repositories: ").strip()
    
    repositories = []
    
    if not target_input:
        # Mặc định - quét thư mục chứa repos
        target_base_path = os.path.join("..", "test-rename-sxf")
        repositories = scan_repositories_in_directory(target_base_path)
        
    elif ';' in target_input:
        # Nhiều đường dẫn repositories cách nhau bằng ;
        print("\n🔍 === XỬ LÝ NHIỀU REPOSITORIES ===")
        repo_paths = [path.strip() for path in target_input.split(';') if path.strip()]
        
        for repo_path in repo_paths:
            repo_path = os.path.abspath(repo_path)
            if os.path.exists(repo_path):
                repo_name = os.path.basename(repo_path)
                # Kiểm tra có phải git repository không
                git_path = os.path.join(repo_path, ".git")
                if os.path.exists(git_path):
                    repositories.append((repo_path, repo_name))
                    print(f"  ✅ {repo_name}: {repo_path}")
                else:
                    print(f"  ⚠️ Không phải git repository: {repo_path}")
            else:
                print(f"  ❌ Không tồn tại: {repo_path}")
                
    else:
        # Kiểm tra xem là 1 repository hay thư mục chứa repos
        target_path = os.path.abspath(target_input)
        
        if not os.path.exists(target_path):
            print(f"❌ Không tìm thấy đường dẫn: {target_path}")
            return
        
        git_path = os.path.join(target_path, ".git")
        if os.path.exists(git_path):
            # Đây là 1 repository
            repo_name = os.path.basename(target_path)
            repositories.append((target_path, repo_name))
            print(f"✅ Single repository: {repo_name}")
        else:
            # Đây là thư mục chứa repositories
            print(f"🔍 Quét thư mục: {target_path}")
            repositories = scan_repositories_in_directory(target_path)
    
    if not repositories:
        print("❌ Không tìm thấy repository nào!")
        return
    
    print(f"\n🎯 Tổng cộng tìm thấy {len(repositories)} repositories")
    
    # Hiển thị thông tin chi tiết
    print(f"\n📋 === CHI TIẾT THAO TÁC ===")
    print(f"📁 Source repository:")
    print(f"  {source_repo_path}")
    print(f"📄 Source files ({len(source_files)}):")
    for filename in source_files.keys():
        print(f"  📄 {filename}")
    print(f"📦 Target repositories ({len(repositories)}):")
    for repo_path, repo_name in repositories:
        print(f"  📦 {repo_name}")
        print(f"      📍 {repo_path}")
    
    # Xác nhận từ người dùng
    response = input(f"\n❓ Bạn có muốn thực hiện copy & replace cho tất cả {len(repositories)} repositories? (y/N): ")
    if response.lower() not in ['y', 'yes']:
        print("🚫 Đã hủy thao tác.")
        return
    
    # Xử lý từng repository
    success_count = 0
    failed_repos = []
    
    for repo_path, repo_name in repositories:
        try:
            if process_repository(source_files, repo_path, repo_name):
                success_count += 1
            else:
                failed_repos.append(repo_name)
        except Exception as e:
            print(f"❌ Lỗi không xác định cho {repo_name}: {e}")
            failed_repos.append(repo_name)
    
    # Kết quả tổng kết
    print(f"\n🏁 === HOÀN THÀNH ===")
    print(f"✅ Thành công: {success_count}/{len(repositories)} repositories")
    print(f"❌ Thất bại: {len(failed_repos)}/{len(repositories)} repositories")
    
    if failed_repos:
        print(f"\n⚠️ Các repositories thất bại:")
        for repo in failed_repos:
            print(f"  ❌ {repo}")
    
    if success_count == len(repositories):
        print("🎉 Tất cả config files đã được copy và replace thành công!")
    elif success_count > 0:
        print("⚠️ Một số repositories đã được xử lý thành công.")
    else:
        print("💥 Không có repository nào được xử lý thành công.")
        
    print(f"\n📊 Tóm tắt:")
    print(f"  📄 Files processed: {list(source_files.keys())}")
    print(f"  📦 Repositories processed: {len(repositories)}")
    print(f"  ✅ Successfully processed: {success_count}")
    print(f"  ❌ Failed: {len(failed_repos)}")

if __name__ == "__main__":
    main()
